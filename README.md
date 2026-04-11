# dhall-play

A small **Dhall + Nix** playground: typed configuration in Dhall, reproducible builds and wrappers in Nix, with examples and tests. The main artifact is a **reusable Nix library** (`lib/configurable-app.nix`) exported from the flake; the dev shell also provides **mask**, **treefmt**, and common tools.

<!-- mdformat-toc start --slug=github --no-anchors --maxlevel=6 --minlevel=1 -->

- [dhall-play](#dhall-play)
  - [Core Nix library](#core-nix-library)
    - [Consuming from another flake](#consuming-from-another-flake)
    - [Flake outputs](#flake-outputs)
  - [Examples](#examples)
  - [Lifecycle (mask)](#lifecycle-mask)
  - [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Quick Start](#quick-start)
    - [Available Tools](#available-tools)
    - [Code Formatting](#code-formatting)
    - [Project Structure](#project-structure)

<!-- mdformat-toc end -->

## Core Nix library

The heart of the repo is **`lib/configurable-app.nix`**: helpers that take a **Dhall config directory** and an **entry file** (e.g. `./server.dhall`), evaluate Dhall in the Nix store, and expose the result as JSON → Nix attrsets and thin app wrappers.

Typical pieces:

- **`dhallConfig` / `dhallConfigJson` / `dhallConfigYaml`** — resolve an entry to structured config or serialized files in the store.
- **`dhallConfigWithOverrides` / `mergeNixConfigs` / `mergeNixConfigsStrict`** — combine Dhall-resolved config with Nix-side overrides or layered attrsets (e.g. secrets injected in Nix, not in committed Dhall).
- **`mkConfigurableShellApp` / `mkConfigurableProcess` / `mkConfigurableNuApp`** — build `writeShellApplication`-style entrypoints that read resolved config and export env vars or run scripts.

The file header in `lib/configurable-app.nix` documents nesting, multiple entries, and when to prefer Dhall merges vs Nix `recursiveUpdate`.

### Consuming from another flake

Import this flake and use **`inputs.<name>.lib.configurableApp`** (or follow `nixpkgs` with `inputs.<name>.inputs.nixpkgs.follows` as usual). The attribute is wired in `flake.nix` under `flake.lib.configurableApp`.

### Flake outputs

- **`lib.configurableApp`** — the library above (for `import` or `follows`).
- **`packages`** — example apps (`alpha-server`, `alpha-client`, `beta-*`, `nu-configured-demo`, `go-greet`, …) built with that library.
- **`checks`** — treefmt formatting check; Dhall type inference (`dhall type`), `dhall freeze --check`, and a negative test on invalid Dhall (see `lib/dhall-ci.nix`, `lib/dhall-ci-entries.nix`).
- **`formatter`** — used by `nix fmt` / `mask format`.

Unit tests for the library and resolved example configs live in **`test.nix`** (run with **`mask test`**).

## Examples

| Area | Role |
| --- | --- |
| `examples/alpha`, `examples/beta` | TCP server/client pairs; Python scripts under `examples/lib/`; Dhall under each `config/`. |
| `examples/nushell-demo`, `examples/go-demo` | Same pattern with Nushell and Go entrypoints. |
| `examples/fixtures-invalid` | Used by flake checks to ensure bad Dhall fails the pipeline. |

To build a package without running the full demo: `nix build .#<name>` (see `flake.nix` `packages`).

## Lifecycle (mask)

| Command | Purpose |
| --- | --- |
| `mask run` | Run the alpha TCP demo (build server + client, one client message). |
| `mask format` | Apply treefmt (`nix fmt`). |
| `mask lint` | `nix flake check` (formatting gate + Dhall CI checks). |
| `mask test` | `nix-unit` on `test.nix`. |

## Getting Started

### Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- [direnv](https://direnv.net/) for automatic environment loading (optional)

### Quick Start

1. Enter the development shell:

   ```bash
   nix develop
   ```

1. Or with direnv installed:

   ```bash
   direnv allow
   ```

### Available Tools

- **mask**: Task runner (`maskfile.md`); primary lifecycle commands above
- **treefmt**: Multi-language formatting (invoked via `nix fmt` / `mask format`)
- **dhall / dhall-json / dhall-nix**: Local Dhall work and inspection
- **nix-unit**: Unit tests (`mask test`)
- **git**, **direnv/nix-direnv**: Version control and automatic env loading

### Code Formatting

Project-wide formatting is defined in `treefmt.nix` and applied with:

```bash
nix fmt
```

or `mask format`.

### Project Structure

```
.
├── flake.nix                 # Flake: lib export, packages, checks, formatter
├── lib/
│   ├── configurable-app.nix  # Core Dhall → Nix library
│   ├── dhall-ci.nix          # Dhall checks for `nix flake check`
│   └── dhall-ci-entries.nix  # Config dirs/entries for `dhall type` and freeze --check
├── examples/                 # Demo apps and Dhall configs
├── test.nix                  # nix-unit tests
├── treefmt.nix               # Formatter configuration
├── maskfile.md               # mask tasks (run, format, lint, test)
├── shell.nix                 # devShell
└── README.md                 # This file
```
