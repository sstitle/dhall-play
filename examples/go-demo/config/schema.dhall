-- Same shape as the Nushell demo; consumed as JSON by the Go binary.
{ Type = { greeting : Text, name : Text, style : Text }
, default = { greeting = "Hello", name = "Nix", style = "plain" }
}
