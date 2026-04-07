# Dhall config directory + entry file → JSON in the store → Nix attrsets / derivations.
#
# Nesting configuration (multiple levels):
# - Prefer composing inside Dhall (imports, record merge, shared schemas) and one `entry` per
#   logical tree, so relative imports and typing stay coherent.
# - When subsystems stay separate (e.g. `api.dhall` + `worker.dhall`), call `dhallConfig` per
#   entry and combine results in Nix with `mergeNixConfigs` (or `lib.recursiveUpdate` yourself).
# - Environment-specific layers (dev/staging/prod) are usually either separate Dhall entry
#   files that import a common base, or one entry that imports `../env/prod.dhall`; avoid
#   duplicating merge rules in both Dhall and Nix unless you need that flexibility.
# - Secrets and last‑mile overrides rarely belong in committed Dhall; inject via Nix (e.g.
#   `recursiveUpdate (dhallConfig …) { token = … }`) or runtime env vars in the wrapper.
let
  # Stable, unique store path name per (configDir, entry) pair.
  configId =
    { configDir, entry }:
    builtins.substring 0 12 (builtins.hashString "sha256" (toString configDir + "\0" + entry));

  dhallConfigJson =
    {
      pkgs,
      configDir,
      entry,
    }:
    let
      id = configId { inherit configDir entry; };
    in
    pkgs.runCommand "dhall-config-${id}.json"
      {
        nativeBuildInputs = [ pkgs.dhall-json ];
      }
      ''
        cp -r ${configDir}/. .
        dhall-to-json <<< ${pkgs.lib.escapeShellArg entry} > $out
      '';

  # Same derivation as `dhallConfigJson`; kept for older call sites.
  dhallConfigJsonPath = dhallConfigJson;

  dhallConfig = args: builtins.fromJSON (builtins.readFile (dhallConfigJson args));

  mergeNixConfigs = { lib, configs }: lib.foldl' lib.recursiveUpdate { } configs;

  mkConfigurableShellApp =
    {
      pkgs,
      name,
      configDir,
      entry,
      text,
      runtimeInputs ? [ ],
    }:
    let
      config = dhallConfig { inherit pkgs configDir entry; };
    in
    pkgs.writeShellApplication {
      inherit name runtimeInputs;
      text = text config;
    };

  # Copy a *.nu file into the store, resolve Dhall `entry`, then run `nu` with `setEnv` exports.
  mkConfigurableNuApp =
    {
      pkgs,
      name,
      configDir,
      entry,
      nuScript,
      setEnv,
      runtimeInputs ? [ ],
    }:
    let
      config = dhallConfig { inherit pkgs configDir entry; };
      nuName = baseNameOf (toString nuScript);
      nuScriptDir = pkgs.runCommand "${name}-nu-${configId { inherit configDir entry; }}" { } ''
        mkdir -p $out
        cp ${nuScript} $out/${nuName}
      '';
    in
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [ pkgs.nushell ] ++ runtimeInputs;
      text = ''
        set -euo pipefail
        ${setEnv config}
        exec ${pkgs.lib.getExe pkgs.nushell} ${nuScriptDir}/${nuName}
      '';
    };
in
{
  inherit
    configId
    dhallConfigJson
    dhallConfigJsonPath
    dhallConfig
    mergeNixConfigs
    mkConfigurableShellApp
    mkConfigurableNuApp
    ;
}
