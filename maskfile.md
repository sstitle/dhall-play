# Maskfile

This is a [mask](https://github.com/jacobdeichert/mask) task runner file.

## hello

> This is an example command you can run with `mask hello`

```bash
echo "Hello World!"
```

## run

> Evaluate the Dhall hello world expression

```bash
dhall <<< './hello.dhall'
```

## test

> Run nix-unit tests

```bash
nix-unit ./test.nix
```
