let Schema = ./client-schema.dhall

in  Schema::{
    , serverHost = "10.0.0.50"
    , serverPort = 4200
    , clientLabel = "beta-user"
    , connectTimeoutSec = 12
    }
