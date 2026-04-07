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
      serverHost = "10.0.0.50";
      serverPort = 4200;
      clientLabel = "beta-user";
      connectTimeoutSec = 12;
    };
  };
}
