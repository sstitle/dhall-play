# Paths and Dhall entry expressions used by `lib/dhall-ci.nix` (`dhall type` + freeze --check).
[
  {
    configDir = ../examples/alpha/config;
    entry = "./server.dhall";
  }
  {
    configDir = ../examples/alpha/config;
    entry = "./client.dhall";
  }
  {
    configDir = ../examples/beta/config;
    entry = "./server.dhall";
  }
  {
    configDir = ../examples/beta/config;
    entry = "./client.dhall";
  }
  {
    configDir = ../examples/go-demo/config;
    entry = "./app.dhall";
  }
  {
    configDir = ../examples/nushell-demo/config;
    entry = "./app.dhall";
  }
]
