{ pkgs, ca }:
let
  inherit (ca) mkConfigurableShellApp;
  configDir = ./config;
in
{
  alpha-server = mkConfigurableShellApp {
    inherit pkgs configDir;
    name = "alpha-server";
    entry = "./server.dhall";
    text = config: ''
      set -euo pipefail
      echo "alpha-server (${config.serviceName})"
      echo "  listen: ${config.listenHost}:${toString config.listenPort}"
    '';
  };

  alpha-client = mkConfigurableShellApp {
    inherit pkgs configDir;
    name = "alpha-client";
    entry = "./client.dhall";
    text = config: ''
      set -euo pipefail
      echo "alpha-client (${config.clientLabel})"
      echo "  connect: ${config.serverHost}:${toString config.serverPort} (timeout ${toString config.connectTimeoutSec}s)"
    '';
  };
}
