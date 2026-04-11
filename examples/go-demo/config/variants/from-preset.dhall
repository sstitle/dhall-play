-- Import preset fields and merge with defaults + tags.
let Schema =
      ../schema.dhall
        sha256:1e5803d5709079543f691520974d6902c920ee1ab301622a6af3c9dd2b87d9b3

let P =
      ../presets.dhall
        sha256:c6a5030ef0fa6e81752aed6ce731c2f5bd22272e011d137ce1b9fd683a15ced7

in      Schema.default
    //  P.vibrant
    //  { name = "from-preset", tags = [ "import", "preset" ] }
