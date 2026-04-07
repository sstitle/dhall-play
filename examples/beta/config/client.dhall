let Schema = ./client-schema.dhall

in  Schema::{
    , serverHost = "127.0.0.1"
    , serverPort = 4200
    , clientLabel = "beta-user"
    , connectTimeoutSec = 12
    , message = "hello from beta client (different port + payload)"
    }
