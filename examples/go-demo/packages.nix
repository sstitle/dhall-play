{ pkgs, ca }:
let
  inherit (ca) dhallConfigJson;
  configDir = ./config;
  configJson = dhallConfigJson {
    inherit pkgs configDir;
    entry = "./app.dhall";
  };
in
{
  go-greet = pkgs.buildGoModule {
    pname = "go-greet";
    version = "0.1.0";
    src = ./go-greet;
    vendorHash = null;
    postPatch = ''
      cp ${configJson} config.json
    '';
  };
}
