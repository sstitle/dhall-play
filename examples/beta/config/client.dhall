let Schema =
      ./client-schema.dhall
        sha256:c7403aaeb3251915a978f02090891557f359cc406cb8678087d6968d996d79c8

in  Schema::{
    , serverHost = "127.0.0.1"
    , serverPort = 4200
    , clientLabel = "beta-user"
    , connectTimeoutSec = 12
    , message = "hello from beta client (different port + payload)"
    }
