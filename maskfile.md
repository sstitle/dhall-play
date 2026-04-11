# Maskfile

Lifecycle tasks for [`mask`](https://github.com/jacobdeichert/mask). Run `mask --help` for a list of commands.

## run

> Build all example packages, then run each demo: alpha TCP (4100), beta TCP (4200), Nushell (four Dhall entry variants), Go (four matching variants).

```bash
set -euo pipefail
repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

nix build \
  .#alpha-server .#alpha-client \
  .#beta-server .#beta-client \
  .#nu-configured-demo .#nu-demo-minimal .#nu-demo-merged .#nu-demo-preset \
  .#go-greet .#go-greet-minimal .#go-greet-merged .#go-greet-preset \
  --no-link

alpha_server="$(nix build .#alpha-server --no-link --print-out-paths)/bin/alpha-server"
alpha_client="$(nix build .#alpha-client --no-link --print-out-paths)/bin/alpha-client"
beta_server="$(nix build .#beta-server --no-link --print-out-paths)/bin/beta-server"
beta_client="$(nix build .#beta-client --no-link --print-out-paths)/bin/beta-client"
nu_default="$(nix build .#nu-configured-demo --no-link --print-out-paths)/bin/nu-configured-demo"
nu_min="$(nix build .#nu-demo-minimal --no-link --print-out-paths)/bin/nu-demo-minimal"
nu_merged="$(nix build .#nu-demo-merged --no-link --print-out-paths)/bin/nu-demo-merged"
nu_preset="$(nix build .#nu-demo-preset --no-link --print-out-paths)/bin/nu-demo-preset"
# buildGoModule names the binary from the Go module (`go-greet`), not `pname` — all variants use bin/go-greet.
go_default="$(nix build .#go-greet --no-link --print-out-paths)/bin/go-greet"
go_min="$(nix build .#go-greet-minimal --no-link --print-out-paths)/bin/go-greet"
go_merged="$(nix build .#go-greet-merged --no-link --print-out-paths)/bin/go-greet"
go_preset="$(nix build .#go-greet-preset --no-link --print-out-paths)/bin/go-greet"

echo ""
echo "=== Alpha TCP (127.0.0.1:4100) ==="
"$alpha_server" &
alpha_pid=$!
trap 'kill "$alpha_pid" 2>/dev/null || true' EXIT
python3 "$repo_root/examples/lib/tcp_wait.py" 127.0.0.1 4100
"$alpha_client"

echo ""
echo "=== Beta TCP (127.0.0.1:4200) ==="
"$beta_server" &
beta_pid=$!
trap 'kill "$alpha_pid" "$beta_pid" 2>/dev/null || true' EXIT
python3 "$repo_root/examples/lib/tcp_wait.py" 127.0.0.1 4200
"$beta_client"

echo ""
echo "=== Nushell — app.dhall (default entry) ==="
"$nu_default"

echo ""
echo "=== Nushell — variants/minimal.dhall (defaults + sparse override) ==="
"$nu_min"

echo ""
echo "=== Nushell — variants/merged.dhall (Schema:: then //) ==="
"$nu_merged"

echo ""
echo "=== Nushell — variants/from-preset.dhall (import presets.dhall) ==="
"$nu_preset"

echo ""
echo "=== Go — app.dhall ==="
"$go_default"

echo ""
echo "=== Go — variants/minimal.dhall ==="
"$go_min"

echo ""
echo "=== Go — variants/merged.dhall ==="
"$go_merged"

echo ""
echo "=== Go — variants/from-preset.dhall ==="
"$go_preset"
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

> Run [nix-unit](https://github.com/nix-community/nix-unit) on `test.nix` (delegates to `test/suite.nix`) and [pytest](https://pytest.org/) on `examples/lib/test_tcp_support.py`

```bash
set -euo pipefail
repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"
export PYTHONPATH="$repo_root/examples/lib"
nix-unit ./test.nix
pytest "$repo_root/examples/lib/test_tcp_support.py"
```
