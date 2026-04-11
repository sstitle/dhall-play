-- Flexible record: tags + note show composition; defaults keep entries small.
{ Type =
    { greeting : Text
    , name : Text
    , style : Text
    , tags : List Text
    , note : Text
    }
, default =
    { greeting = "Hello"
    , name = "Nix"
    , style = "plain"
    , tags = [] : List Text
    , note = ""
    }
}
