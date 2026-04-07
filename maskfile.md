# Maskfile

This is a [mask](https://github.com/jacobdeichert/mask) task runner file.

## hello

> This is an example command you can run with `mask hello`

```bash
echo "Hello World!"
```

## run

> Show the resolved production config as a Nix expression

```bash
cd examples/alpha/config && dhall-to-nix <<< "./server.dhall"
```

## build

> Build and run the app with config baked in from Dhall

```bash
nix build .#alpha-server && ./result/bin/alpha-server
nix build .#alpha-client && ./result/bin/alpha-client
nix build .#beta-server && ./result/bin/beta-server
nix build .#beta-client && ./result/bin/beta-client
```

## test

> Run nix-unit tests

```bash
nix-unit ./test.nix
```

## alpha-tcp-demo

> Build alpha server and client, run server in the background, send one TCP message from the client (localhost:4100)

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

## beta-tcp-demo

> Same for the beta pair (localhost:4200, different Dhall-injected message)

```bash
set -euo pipefail
server_bin="$(nix build .#beta-server --no-link --print-out-paths)/bin/beta-server"
client_bin="$(nix build .#beta-client --no-link --print-out-paths)/bin/beta-client"
"$server_bin" &
pid=$!
trap 'kill "$pid" 2>/dev/null || true' EXIT
sleep 0.5
"$client_bin"
```
