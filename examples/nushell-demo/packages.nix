{ pkgs, ca }:
let
  inherit (ca) mkConfigurableNuApp;
  configDir = ./config;
in
{
  nu-configured-demo = mkConfigurableNuApp {
    inherit pkgs configDir;
    name = "nu-configured-demo";
    entry = "./app.dhall";
    nuScript = ./hello.nu;
    setEnv = config: ''
      export NU_GREETING=${pkgs.lib.escapeShellArg config.greeting}
      export NU_NAME=${pkgs.lib.escapeShellArg config.name}
      export NU_STYLE=${pkgs.lib.escapeShellArg config.style}
    '';
  };
}
