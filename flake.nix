{
  description = "Dhall + Nix configurable apps (flake lib), examples, treefmt, and mask tasks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    nix-unit.url = "github:nix-community/nix-unit";
    nix-unit.inputs.nixpkgs.follows = "nixpkgs";
    nix-unit.inputs.flake-parts.follows = "flake-parts";
    nix-unit.inputs.treefmt-nix.follows = "treefmt-nix";
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.nix-unit.modules.flake.default
      ];

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
      };

      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          lib,
          ...
        }:
        let
          treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
          configurableApp = self.lib.configurableApp;
          nixUnitOverrideArg =
            name: value: "--override-input ${lib.escapeShellArg name} ${lib.escapeShellArg "${value}"}";
          dhallCiEntries = import ./lib/dhall-ci-entries.nix;
          dhallCi = import ./lib/dhall-ci.nix {
            inherit pkgs;
            lib = pkgs.lib;
            entries = dhallCiEntries;
          };
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
          goDemo = import ./examples/go-demo/packages.nix {
            inherit pkgs;
            ca = configurableApp;
          };
        in
        {
          nix-unit.inputs = {
            inherit (inputs)
              nixpkgs
              flake-parts
              nix-unit
              treefmt-nix
              ;
          };

          nix-unit.tests = import ./test/suite.nix {
            inherit pkgs;
            ca = configurableApp;
          };

          packages = {
            default = alpha.alpha-server;
            inherit (alpha) alpha-server alpha-client;
            inherit (beta) beta-server beta-client;
            inherit (nushellDemo)
              nu-configured-demo
              nu-demo-minimal
              nu-demo-merged
              nu-demo-preset
              ;
            inherit (goDemo)
              go-greet
              go-greet-minimal
              go-greet-merged
              go-greet-preset
              ;
          };

          devShells.default = import ./shell.nix { inherit pkgs; };

          # for `nix fmt`
          formatter = treefmtEval.config.build.wrapper;

          # for `nix flake check`
          checks = {
            formatting = treefmtEval.config.build.check self;
            inherit (dhallCi)
              dhallTypecheck
              dhallFreezeCheck
              dhallInvalidSyntaxRejected
              ;
            # Upstream `checks.nix-unit` omits `pkgs.nix`; realising test derivations then fails with
            # "Could not find executable 'nix'" (Nix 2.30+ build hooks). See nix-community/nix-unit#183.
            #
            # Run `nix-unit ./test.nix` from a copy of the flake (same as `mask test`), not
            # `nix-unit --flake …#tests.systems.*`: nested `--flake` evaluation is brittle in the
            # sandbox and can diverge from the CLI entrypoint.
            nix-unit = lib.mkForce (
              pkgs.runCommand "nix-unit-check"
                {
                  nativeBuildInputs = [
                    pkgs.nix
                    config.nix-unit.package
                  ];
                  key = "";
                }
                ''
                  export HOME="$(realpath .)"
                  cp -r ${self} ./flake-src
                  chmod -R u+w ./flake-src
                  cd ./flake-src
                  echo "Running nix-unit on test.nix for " ${lib.escapeShellArg system}
                  nix-unit \
                    --show-trace \
                    --extra-experimental-features flakes \
                    --accept-flake-config \
                    ${lib.concatStringsSep "\\\n  " (lib.mapAttrsToList nixUnitOverrideArg config.nix-unit.inputs)} \
                    ./test.nix \
                    ;
                  echo "Writing \"$key\" to $out"
                  echo -n "$key" > $out
                ''
            );
          };
        };
    };
}
