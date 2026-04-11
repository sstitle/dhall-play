# CI derivations: Dhall type inference (`dhall type`), `dhall freeze --check`, and invalid-syntax rejection.
{
  pkgs,
  lib,
  entries,
}:
{
  dhallTypecheck =
    pkgs.runCommand "dhall-typecheck-ci"
      {
        nativeBuildInputs = [ pkgs.dhall ];
      }
      ''
        set -euo pipefail
        ${lib.concatMapStringsSep "\n" (
          { configDir, entry }:
          ''
            work=$(mktemp -d)
            cp -r ${configDir}/. "$work"
            chmod -R u+w "$work"
            (cd "$work" && dhall type <<< ${lib.escapeShellArg entry})
            rm -rf "$work"
          ''
        ) entries}
        touch $out
      '';

  dhallFreezeCheck =
    pkgs.runCommand "dhall-freeze-check-ci"
      {
        nativeBuildInputs = [ pkgs.dhall ];
      }
      ''
        set -euo pipefail
        ${lib.concatMapStringsSep "\n" (
          { configDir, entry }:
          ''
            work=$(mktemp -d)
            cp -r ${configDir}/. "$work"
            chmod -R u+w "$work"
            (cd "$work" && dhall freeze --check <<< ${lib.escapeShellArg entry})
            rm -rf "$work"
          ''
        ) entries}
        touch $out
      '';

  dhallInvalidSyntaxRejected =
    let
      invalidConfigDir = ../examples/fixtures-invalid;
    in
    pkgs.runCommand "dhall-invalid-syntax-rejected"
      {
        nativeBuildInputs = [ pkgs.dhall-json ];
      }
      ''
        set +e
        cp -r ${invalidConfigDir}/. .
        dhall-to-json <<< "./invalid.dhall" > /dev/null 2>&1
        status=$?
        set -e
        if [ "$status" -eq 0 ]; then
          echo "expected dhall-to-json to fail on invalid.dhall" >&2
          exit 1
        fi
        touch $out
      '';
}
