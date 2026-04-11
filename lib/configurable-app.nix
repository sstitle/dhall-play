# Dhall config directory + entry file → JSON in the store → Nix attrsets / derivations.
#
# Public-ish exports: `configId` is a stable sha256-based label for store paths (treat as an
# implementation detail for semver). `dhallConfigJsonPath` is an alias of `dhallConfigJson` for
# older call sites; prefer `dhallConfigJson`.
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
#   `dhallConfigWithOverrides` or `recursiveUpdate (dhallConfig …) { token = … }`) or runtime
#   env vars in the wrapper. For encrypted secrets at deploy time, pair Nix overrides with
#   tools such as sops-nix or agenix instead of putting material in Dhall.
let
  # Stable, unique store path name per (configDir, entry) pair (full sha256 hex digest).
  configId = { configDir, entry }: builtins.hashString "sha256" (toString configDir + "\0" + entry);

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
        set -euo pipefail
        cp -r ${configDir}/. .
        if ! dhall-to-json <<< ${pkgs.lib.escapeShellArg entry} > "$out" 2>dhall.stderr; then
          echo "dhall-to-json failed:" >&2
          cat dhall.stderr >&2
          exit 1
        fi
      '';

  # Same derivation as `dhallConfigJson`; kept for older call sites.
  dhallConfigJsonPath = dhallConfigJson;

  # YAML on disk for runtimes that read YAML (not parsed back into Nix here).
  dhallConfigYaml =
    {
      pkgs,
      configDir,
      entry,
    }:
    let
      id = configId { inherit configDir entry; };
    in
    pkgs.runCommand "dhall-config-${id}.yaml"
      {
        nativeBuildInputs = [ pkgs.dhall-yaml ];
      }
      ''
        set -euo pipefail
        cp -r ${configDir}/. .
        if ! ${pkgs.lib.getExe' pkgs.dhall-yaml "dhall-to-yaml-ng"} <<< ${pkgs.lib.escapeShellArg entry} > "$out" 2>dhall.stderr; then
          echo "dhall-to-yaml-ng failed:" >&2
          cat dhall.stderr >&2
          exit 1
        fi
      '';

  dhallConfig = args: builtins.fromJSON (builtins.readFile (dhallConfigJson args));

  # Identity helper for tests or callers that already have an attrset shaped like `dhallConfig`.
  dhallConfigFromAttrs = attrs: attrs;

  dhallConfigWithOverrides =
    {
      lib,
      pkgs,
      configDir,
      entry,
      overrides,
    }:
    lib.recursiveUpdate (dhallConfig { inherit pkgs configDir entry; }) overrides;

  # Directory whose `$out/<name>` is the resolved JSON (e.g. `cp "$out/config.json" …`).
  dhallConfigJsonNamed =
    {
      pkgs,
      configDir,
      entry,
      name ? "config.json",
    }:
    let
      json = dhallConfigJson { inherit pkgs configDir entry; };
      id = configId { inherit configDir entry; };
    in
    pkgs.runCommand "dhall-config-named-${id}" { } ''
      mkdir -p "$out"
      cp ${json} "$out/${name}"
    '';

  mergeNixConfigs = { lib, configs }: lib.foldl' lib.recursiveUpdate { } configs;

  mergeNixConfigsStrict =
    { lib, configs }:
    let
      mergePair =
        path: a: b:
        let
          keys = lib.unique (lib.attrNames a ++ lib.attrNames b);
          mergeKey =
            k:
            let
              hasA = a ? ${k};
              hasB = b ? ${k};
              here = path ++ [ k ];
              hereStr = lib.concatStringsSep "." here;
            in
            if hasA && hasB then
              let
                av = a.${k};
                bv = b.${k};
              in
              if lib.isAttrs av && lib.isAttrs bv then
                mergePair here av bv
              else if av == bv then
                av
              else
                throw "configurableApp.mergeNixConfigsStrict: conflicting values at ${hereStr}: ${lib.generators.toPretty { } av} vs ${lib.generators.toPretty { } bv}"
            else if hasA then
              a.${k}
            else
              b.${k};
        in
        lib.genAttrs keys mergeKey;
    in
    lib.foldl' (acc: x: mergePair [ ] acc x) { } configs;

  # { entries = { alpha-server = "./server.dhall"; }; } → { alpha-server = <attrset>; … }
  dhallConfigEntries =
    {
      pkgs,
      configDir,
      entries,
    }:
    builtins.mapAttrs (name: entry: dhallConfig { inherit pkgs configDir entry; }) entries;

  mkConfigurableProcess =
    {
      pkgs,
      name,
      configDir,
      entry,
      config ? null,
      runtimeInputs ? [ ],
      text,
    }:
    let
      resolved = if config != null then config else dhallConfig { inherit pkgs configDir entry; };
    in
    pkgs.writeShellApplication {
      inherit name runtimeInputs;
      text = text resolved;
    };

  mkConfigurableShellApp =
    {
      pkgs,
      name,
      configDir,
      entry,
      config ? null,
      text,
      runtimeInputs ? [ ],
    }:
    mkConfigurableProcess {
      inherit
        pkgs
        name
        configDir
        entry
        config
        runtimeInputs
        text
        ;
    };

  # Copy a *.nu file into the store, resolve Dhall `entry`, then run `nu` with `setEnv` exports.
  mkConfigurableNuApp =
    {
      pkgs,
      name,
      configDir,
      entry,
      config ? null,
      nuScript,
      setEnv,
      runtimeInputs ? [ ],
    }:
    let
      resolved = if config != null then config else dhallConfig { inherit pkgs configDir entry; };
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
        ${setEnv resolved}
        exec ${pkgs.lib.getExe pkgs.nushell} ${nuScriptDir}/${nuName}
      '';
    };
in
{
  inherit
    configId
    dhallConfigJson
    dhallConfigJsonPath
    dhallConfigYaml
    dhallConfig
    dhallConfigFromAttrs
    dhallConfigWithOverrides
    dhallConfigJsonNamed
    mergeNixConfigs
    mergeNixConfigsStrict
    dhallConfigEntries
    mkConfigurableProcess
    mkConfigurableShellApp
    mkConfigurableNuApp
    ;
}
