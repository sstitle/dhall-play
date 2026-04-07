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
