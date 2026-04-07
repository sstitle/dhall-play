let Schema = ./client-schema.dhall

in  Schema::{ serverPort = 4100, clientLabel = "alpha-user", connectTimeoutSec = 3 }
