module Data.Author exposing (Author, encode, decoder, init, name, mapValue, value)


import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)


-- Model --


type Author =
    Author Internals


type alias Internals =
    { name : String
    , value : Bool
    }


-- TODO: remove this
init : String -> Author
init name_ =
    Author { name = name_, value = True }


-- Accessors --


-- name


name : Author -> String
name (Author internals) =
    internals.name


-- value


mapValue : (Bool -> Bool) -> Author -> Author
mapValue transform (Author internals) =
    Author { internals | value = transform internals.value }


value : Author -> Bool
value (Author internals) =
    internals.value


-- JSON --


decoder : Decoder Author
decoder =
    Decode.succeed Internals
        |> required "name" Decode.string
        |> required "value" Decode.bool
        |> Decode.map Author


encode : Author -> Value
encode (Author internals) =
    Encode.object
        [ ( "name", Encode.string internals.name )
        , ( "value", Encode.bool internals.value )
        ]
