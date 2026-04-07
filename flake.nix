{
  description = "Development environment with 'mask' task runner and 'treefmt' code formatter";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        # keep-sorted start
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
        # keep-sorted end
      ];

      flake = {
        lib = {
          # For other flakes: `inputs.dhall-play.lib.configurableApp` (follow `nixpkgs` via `inputs.*.follows`).
          configurableApp = import ./lib/configurable-app.nix;
        };
        tests = import ./test.nix;
      };

      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        let
          treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
          configurableApp = self.lib.configurableApp;
          alpha = import ./examples/alpha/packages.nix {
            inherit pkgs;
            ca = configurableApp;
          };
          beta = import ./examples/beta/packages.nix {
            inherit pkgs;
            ca = configurableApp;
          };
          nushellDemo = import ./examples/nushell-demo/packages.nix {
            inherit pkgs;
            ca = configurableApp;
          };
        in
        {
          packages = {
            default = alpha.alpha-server;
            inherit (alpha) alpha-server alpha-client;
            inherit (beta) beta-server beta-client;
            inherit (nushellDemo) nu-configured-demo;
          };

          devShells.default = import ./shell.nix { inherit pkgs; };

          # for `nix fmt`
          formatter = treefmtEval.config.build.wrapper;

          # for `nix flake check`
          checks = {
            formatting = treefmtEval.config.build.check self;
          };
        };
    };
}
