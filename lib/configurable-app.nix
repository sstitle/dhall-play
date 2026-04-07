# Reusable helpers: Dhall config trees → JSON → Nix attrsets, plus shell app wiring.
let
  dhallConfigJsonPath =
    {
      pkgs,
      configDir,
      entry,
    }:
    pkgs.runCommand "dhall-config.json"
      {
        nativeBuildInputs = [ pkgs.dhall-json ];
      }
      ''
        cp -r ${configDir}/. .
        dhall-to-json <<< ${pkgs.lib.escapeShellArg entry} > $out
      '';

  dhallConfig = args: builtins.fromJSON (builtins.readFile (dhallConfigJsonPath args));

  mkConfigurableShellApp =
    {
      pkgs,
      name,
      configDir,
      entry,
      text,
    }:
    let
      config = dhallConfig { inherit pkgs configDir entry; };
    in
    pkgs.writeShellApplication {
      inherit name;
      text = text config;
    };
in
{
  inherit dhallConfigJsonPath dhallConfig mkConfigurableShellApp;
}
