module Data.Tag exposing (Tag, decoder, encode, init, mapValue, name, value, toSource)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)
import Data.Search as Search exposing (Source)


type Tag
    = Tag Internals


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


-- Util


toSource : msg -> List Tag -> Source msg
toSource msg tags =
    Search.source
        ( List.map
            (\(Tag t) -> 
                t.name
            )
            tags
        )
        "tag"
        msg

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
