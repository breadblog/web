module Data.Tag exposing (Tag, decoder, encode, name, value, mapValue, init)


import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)


type Tag =
    Tag Internals


type alias Internals =
    { name : String
    , value : Bool
    }


-- TODO: Remove
init : String -> Tag
init name_ =
    Tag
        { name = name_
        , value = True
        }


-- Accessors --


-- name


name : Tag -> String
name (Tag internals) =
    internals.name


-- value


value : Tag -> Bool
value (Tag internals) =
    internals.value


mapValue : (Bool -> Bool) -> Tag -> Tag
mapValue transform (Tag internals) =
    Tag { internals | value = transform internals.value }


-- JSON --

decoder : Decoder Tag
decoder =
    Decode.succeed Internals
        |> required "name" Decode.string
        |> required "value" Decode.bool
        |> Decode.map Tag


encode : Tag -> Value
encode (Tag tag) =
    Encode.object
        [ ( "name", Encode.string tag.name )
        , ( "value", Encode.bool tag.value )
        ]
