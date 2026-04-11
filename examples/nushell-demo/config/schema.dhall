-- Minimal demo: values flow Dhall → Nix → env → Nushell.
{ Type = { greeting : Text, name : Text, style : Text }
, default = { greeting = "Hello", name = "Nix", style = "plain" }
}
