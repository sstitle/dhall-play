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
++ (mk ../examples/go-demo/config [ "./app.dhall" ])
++ (mk ../examples/nushell-demo/config [ "./app.dhall" ])
