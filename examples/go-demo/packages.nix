{ pkgs, ca }:
let
  inherit (ca) dhallConfigJsonNamed;
  configDir = ./config;
  configDirOut = dhallConfigJsonNamed {
    inherit pkgs configDir;
    entry = "./app.dhall";
    name = "config.json";
  };
in
{
  go-greet = pkgs.buildGoModule {
    pname = "go-greet";
    version = "0.1.0";
    src = ./go-greet;
    vendorHash = null;
    postPatch = ''
      cp ${configDirOut}/config.json config.json
    '';
  };
}
