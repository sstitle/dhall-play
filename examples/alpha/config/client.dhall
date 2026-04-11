let Schema =
      ./client-schema.dhall
        sha256:c7403aaeb3251915a978f02090891557f359cc406cb8678087d6968d996d79c8

in  Schema::{
    , serverPort = 4100
    , clientLabel = "alpha-user"
    , connectTimeoutSec = 3
    , message = "hello from alpha client"
    }
