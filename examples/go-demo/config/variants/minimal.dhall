-- Defaults + small override (sparse config).
let Schema =
      ../schema.dhall
        sha256:1e5803d5709079543f691520974d6902c920ee1ab301622a6af3c9dd2b87d9b3

in      Schema.default
    //  { name = "minimal"
        , tags = [ "sparse" ]
        , note = "defaults // { name, tags, note }"
        }
