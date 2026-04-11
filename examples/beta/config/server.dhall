let Schema =
      ./server-schema.dhall
        sha256:33436cdc6955b5c9f312ffbee2ee506949a8ce1c8d211afb8bb674d998cd9a1e

in  Schema::{ serviceName = "beta-peer", listenPort = 4200 }
