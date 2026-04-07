let Schema = ./schema.dhall

-- Schema::{ ... } enforces the contract: omitting `databaseUrl` is a type error.
in  Schema::{
    , port = 443
    , databaseUrl = "postgres://db.prod.example.com/myapp"
    , logLevel = "warn"
    }
