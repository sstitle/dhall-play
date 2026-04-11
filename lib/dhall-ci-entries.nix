# Paths and Dhall entry expressions used by `lib/dhall-ci.nix` (`dhall type` + freeze --check).
let
  mk = configDir: files: map (entry: { inherit configDir entry; }) files;
in
(mk ../examples/alpha/config [
  "./server.dhall"
  "./client.dhall"
])
++ (mk ../examples/beta/config [
  "./server.dhall"
  "./client.dhall"
])
++ (mk ../examples/go-demo/config [
  "./schema.dhall"
  "./presets.dhall"
  "./app.dhall"
  "./variants/minimal.dhall"
  "./variants/merged.dhall"
  "./variants/from-preset.dhall"
])
++ (mk ../examples/nushell-demo/config [
  "./schema.dhall"
  "./presets.dhall"
  "./app.dhall"
  "./variants/minimal.dhall"
  "./variants/merged.dhall"
  "./variants/from-preset.dhall"
])
