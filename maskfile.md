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
cd config && dhall-to-nix <<< "./production.dhall"
```

## build

> Build and run the app with config baked in from Dhall

```bash
nix build && ./result/bin/my-app
```

## test

> Run nix-unit tests

```bash
nix-unit ./test.nix
```
