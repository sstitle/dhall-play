-- The application configuration contract.
-- Fields in `default` are optional; fields absent from `default` are required.
{ Type =
    { host : Text
    , port : Natural
    , databaseUrl : Text
    , logLevel : Text
    , workerCount : Natural
    }
, default =
    { host = "0.0.0.0"
    , port = 8080
    , logLevel = "info"
    , workerCount = 4
    }
}
