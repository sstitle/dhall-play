let
  pkgs = import <nixpkgs> { };
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
}
