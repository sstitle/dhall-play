-- Full Schema:: record, then merge (//) to layer tags + note.
let Schema =
      ../schema.dhall
        sha256:1e5803d5709079543f691520974d6902c920ee1ab301622a6af3c9dd2b87d9b3

let base =
      Schema::{
      , greeting = "Hello"
      , name = "merge-base"
      , style = "plain"
      , tags = [] : List Text
      , note = ""
      }

in      base
    //  { greeting = "Merged via //"
        , tags = [ "dhall", "merge" ]
        , note = "Schema::{…} then record merge"
        }
