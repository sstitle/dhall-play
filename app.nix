{ pkgs }:
let
  # Run dhall-to-json over the config directory so relative imports resolve
  configJson = pkgs.runCommand "app-config.json" {
    buildInputs = [ pkgs.dhall-json ];
  } ''
    cp -r ${./config}/. .
    dhall-to-json <<< "./production.dhall" > $out
  '';

  config = builtins.fromJSON (builtins.readFile configJson);
in
pkgs.writeShellApplication {
  name = "my-app";
  text = ''
    echo "Starting my-app"
    echo "  host:    ${config.host}"
    echo "  port:    ${toString config.port}"
    echo "  db:      ${config.databaseUrl}"
    echo "  log:     ${config.logLevel}"
    echo "  workers: ${toString config.workerCount}"
  '';
}
