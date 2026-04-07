{ pkgs, ca }:
let
  inherit (ca) mkConfigurableShellApp;
  configDir = ./config;
in
{
  beta-server = mkConfigurableShellApp {
    inherit pkgs configDir;
    name = "beta-server";
    entry = "./server.dhall";
    text = config: ''
      set -euo pipefail
      echo "beta-server (${config.serviceName})"
      echo "  listen: ${config.listenHost}:${toString config.listenPort}"
    '';
  };

  beta-client = mkConfigurableShellApp {
    inherit pkgs configDir;
    name = "beta-client";
    entry = "./client.dhall";
    text = config: ''
      set -euo pipefail
      echo "beta-client (${config.clientLabel})"
      echo "  connect: ${config.serverHost}:${toString config.serverPort} (timeout ${toString config.connectTimeoutSec}s)"
    '';
  };
}
