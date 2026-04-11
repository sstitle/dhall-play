# nix-unit entrypoint for `mask test`: resolves pinned `nixpkgs` from this flake, then delegates to `test/suite.nix`.
let
  pkgs = import (builtins.getFlake (toString ./.)).inputs.nixpkgs { };
  ca = import ./lib/configurable-app.nix;
in
import ./test/suite.nix { inherit pkgs ca; }
