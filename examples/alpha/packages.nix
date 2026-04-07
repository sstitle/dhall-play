{ pkgs, ca }:
let
  inherit (ca) mkConfigurableShellApp;
  configDir = ./config;
  tcpServer = ./../lib/tcp_server.py;
  tcpClient = ./../lib/tcp_client.py;
in
{
  alpha-server = mkConfigurableShellApp {
    inherit pkgs configDir;
    name = "alpha-server";
    entry = "./server.dhall";
    runtimeInputs = [ pkgs.python3 ];
    text = config: ''
      set -euo pipefail
      export TCP_LISTEN_HOST=${pkgs.lib.escapeShellArg config.listenHost}
      export TCP_LISTEN_PORT=${toString config.listenPort}
      export TCP_SERVICE_NAME=${pkgs.lib.escapeShellArg config.serviceName}
      exec ${pkgs.python3}/bin/python3 ${tcpServer}
    '';
  };

  alpha-client = mkConfigurableShellApp {
    inherit pkgs configDir;
    name = "alpha-client";
    entry = "./client.dhall";
    runtimeInputs = [ pkgs.python3 ];
    text = config: ''
      set -euo pipefail
      export TCP_REMOTE_HOST=${pkgs.lib.escapeShellArg config.serverHost}
      export TCP_REMOTE_PORT=${toString config.serverPort}
      export TCP_MESSAGE=${pkgs.lib.escapeShellArg config.message}
      export TCP_TIMEOUT_SEC=${toString config.connectTimeoutSec}
      export TCP_CLIENT_LABEL=${pkgs.lib.escapeShellArg config.clientLabel}
      exec ${pkgs.python3}/bin/python3 ${tcpClient}
    '';
  };
}
