{ pkgs, ca }:
let
  inherit (ca) mkConfigurableNuApp;
  configDir = ./config;
  setEnv = config: ''
    export NU_GREETING=${pkgs.lib.escapeShellArg config.greeting}
    export NU_NAME=${pkgs.lib.escapeShellArg config.name}
    export NU_STYLE=${pkgs.lib.escapeShellArg config.style}
    export NU_TAGS_JSON=${pkgs.lib.escapeShellArg (builtins.toJSON config.tags)}
    export NU_NOTE=${pkgs.lib.escapeShellArg config.note}
  '';
  mkNu =
    name: entry:
    mkConfigurableNuApp {
      inherit
        pkgs
        configDir
        name
        setEnv
        ;
      entry = entry;
      nuScript = ./hello.nu;
    };
in
{
  nu-configured-demo = mkNu "nu-configured-demo" "./app.dhall";
  nu-demo-minimal = mkNu "nu-demo-minimal" "./variants/minimal.dhall";
  nu-demo-merged = mkNu "nu-demo-merged" "./variants/merged.dhall";
  nu-demo-preset = mkNu "nu-demo-preset" "./variants/from-preset.dhall";
}
