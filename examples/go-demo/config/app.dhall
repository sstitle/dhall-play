let Schema =
      ./schema.dhall
        sha256:1c4ab266cfdb3c64bd174e239fc9d4e17ff49505eef58c55406e694ad193eb2d

in  Schema::{
    , greeting = "Configured in Dhall"
    , name = "Go"
    , style = "embedded-json"
    }
