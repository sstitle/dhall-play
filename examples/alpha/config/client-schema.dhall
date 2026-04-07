-- Client-side: where to reach the peer and how long to wait.
{ Type =
    { serverHost : Text
    , serverPort : Natural
    , clientLabel : Text
    , connectTimeoutSec : Natural
    }
, default =
    { serverHost = "127.0.0.1"
    , serverPort = 8080
    , connectTimeoutSec = 5
    }
}
