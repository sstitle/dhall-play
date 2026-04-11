# Maskfile

Lifecycle tasks for [`mask`](https://github.com/jacobdeichert/mask). Run `mask --help` for a list of commands.

## run

> Build the alpha TCP demo (server + client from Dhall-backed config), start the server, send one message from the client (localhost:4100)

```bash
set -euo pipefail
server_bin="$(nix build .#alpha-server --no-link --print-out-paths)/bin/alpha-server"
client_bin="$(nix build .#alpha-client --no-link --print-out-paths)/bin/alpha-client"
"$server_bin" &
pid=$!
trap 'kill "$pid" 2>/dev/null || true' EXIT
sleep 0.5
"$client_bin"
```

## format

> Format the tree using the flake formatter ([treefmt](https://github.com/numtide/treefmt) via `treefmt.nix`: nixfmt, mdformat, keep-sorted, …)

```bash
nix fmt
```

## lint

> Run `nix flake check`: formatting check, Dhall type inference (`dhall type`) and `dhall freeze --check` on configured entries, and rejection of invalid Dhall syntax in the fixture

```bash
nix flake check
```

## test

> Run [nix-unit](https://github.com/nix-community/nix-unit) tests against `test.nix`

```bash
nix-unit ./test.nix
```
