let
  flake = builtins.getFlake (toString ./.);
  pkgs = import flake.inputs.nixpkgs { };
  ca = import ./lib/configurable-app.nix;
in
{
  testDhallConfigAlphaServer = {
    expr = ca.dhallConfig {
      inherit pkgs;
      configDir = ./examples/alpha/config;
      entry = "./server.dhall";
    };
    expected = {
      listenHost = "127.0.0.1";
      listenPort = 4100;
      serviceName = "alpha-peer";
    };
  };

  testDhallConfigAlphaClient = {
    expr = ca.dhallConfig {
      inherit pkgs;
      configDir = ./examples/alpha/config;
      entry = "./client.dhall";
    };
    expected = {
      serverHost = "127.0.0.1";
      serverPort = 4100;
      clientLabel = "alpha-user";
      connectTimeoutSec = 3;
      message = "hello from alpha client";
    };
  };

  testDhallConfigBetaServer = {
    expr = ca.dhallConfig {
      inherit pkgs;
      configDir = ./examples/beta/config;
      entry = "./server.dhall";
    };
    expected = {
      listenHost = "127.0.0.1";
      listenPort = 4200;
      serviceName = "beta-peer";
    };
  };

  testDhallConfigBetaClient = {
    expr = ca.dhallConfig {
      inherit pkgs;
      configDir = ./examples/beta/config;
      entry = "./client.dhall";
    };
    expected = {
      serverHost = "127.0.0.1";
      serverPort = 4200;
      clientLabel = "beta-user";
      connectTimeoutSec = 12;
      message = "hello from beta client (different port + payload)";
    };
  };

  testMergeNixConfigs = {
    expr = ca.mergeNixConfigs {
      lib = pkgs.lib;
      configs = [
        { a = 1; }
        { b = 2; }
        { a = 3; }
      ];
    };
    expected = {
      a = 3;
      b = 2;
    };
  };

  testDhallConfigGoDemo = {
    expr = ca.dhallConfig {
      inherit pkgs;
      configDir = ./examples/go-demo/config;
      entry = "./app.dhall";
    };
    expected = {
      greeting = "Configured in Dhall";
      name = "Go";
      style = "embedded-json";
    };
  };

  testDhallConfigNushellDemo = {
    expr = ca.dhallConfig {
      inherit pkgs;
      configDir = ./examples/nushell-demo/config;
      entry = "./app.dhall";
    };
    expected = {
      greeting = "Configured in Dhall";
      name = "NuShell";
      style = "friendly";
    };
  };

  testDhallConfigJsonDistinctEntries = {
    expr = (
      toString (
        ca.dhallConfigJson {
          inherit pkgs;
          configDir = ./examples/alpha/config;
          entry = "./server.dhall";
        }
      ) != toString (
        ca.dhallConfigJson {
          inherit pkgs;
          configDir = ./examples/alpha/config;
          entry = "./client.dhall";
        }
      )
    );
    expected = true;
  };

  testDhallConfigFromAttrs = {
    expr = ca.dhallConfigFromAttrs {
      greeting = "x";
      name = "y";
      style = "z";
    };
    expected = {
      greeting = "x";
      name = "y";
      style = "z";
    };
  };

  testDhallConfigWithOverrides = {
    expr = ca.dhallConfigWithOverrides {
      lib = pkgs.lib;
      inherit pkgs;
      configDir = ./examples/go-demo/config;
      entry = "./app.dhall";
      overrides = {
        name = "Patched";
      };
    };
    expected = {
      greeting = "Configured in Dhall";
      name = "Patched";
      style = "embedded-json";
    };
  };

  testDhallConfigEntries = {
    expr =
      (ca.dhallConfigEntries {
        inherit pkgs;
        configDir = ./examples/go-demo/config;
        entries = {
          foo = "./app.dhall";
        };
      }).foo;
    expected = ca.dhallConfig {
      inherit pkgs;
      configDir = ./examples/go-demo/config;
      entry = "./app.dhall";
    };
  };

  testMergeNixConfigsStrictOk = {
    expr = ca.mergeNixConfigsStrict {
      lib = pkgs.lib;
      configs = [
        {
          a = {
            b = 1;
          };
        }
        {
          a = {
            c = 2;
          };
        }
      ];
    };
    expected = {
      a = {
        b = 1;
        c = 2;
      };
    };
  };

  testMergeNixConfigsStrictSameValue = {
    expr = ca.mergeNixConfigsStrict {
      lib = pkgs.lib;
      configs = [
        { a = 1; }
        { a = 1; }
      ];
    };
    expected = {
      a = 1;
    };
  };

  testMergeNixConfigsStrictConflict = {
    expr =
      (builtins.tryEval (
        builtins.deepSeq (ca.mergeNixConfigsStrict {
          lib = pkgs.lib;
          configs = [
            { a = 1; }
            { a = 2; }
          ];
        }) null
      )).success;
    expected = false;
  };

  testDhallConfigYamlContainsKeys = {
    expr = pkgs.lib.hasInfix "Configured" (
      builtins.readFile (
        ca.dhallConfigYaml {
          inherit pkgs;
          configDir = ./examples/go-demo/config;
          entry = "./app.dhall";
        }
      )
    );
    expected = true;
  };
}
