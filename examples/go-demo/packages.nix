{ pkgs, ca }:
let
  inherit (ca) dhallConfigJsonNamed;
  configDir = ./config;
  mkGo =
    pname: entry:
    let
      configDirOut = dhallConfigJsonNamed {
        inherit pkgs configDir entry;
        name = "config.json";
      };
    in
    pkgs.buildGoModule {
      inherit pname;
      version = "0.1.0";
      src = ./go-greet;
      vendorHash = null;
      postPatch = ''
        cp ${configDirOut}/config.json config.json
      '';
      meta.mainProgram = "go-greet";
    };
in
{
  go-greet = mkGo "go-greet" "./app.dhall";
  go-greet-minimal = mkGo "go-greet-minimal" "./variants/minimal.dhall";
  go-greet-merged = mkGo "go-greet-merged" "./variants/merged.dhall";
  go-greet-preset = mkGo "go-greet-preset" "./variants/from-preset.dhall";
}
