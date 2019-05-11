module Data.Tag exposing (Tag, decoder, encode, mapWatched, mocks, name, toSource, watched)

import Data.Search as Search exposing (Source)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode exposing (Value)



{- Model -}


type Tag
    = Tag Internals


type alias Internals =
    { name : String
    , description : String
    , watched : Bool
    }



{- Accessors -}


name : Tag -> String
name (Tag internals) =
    internals.name


watched : Tag -> Bool
watched (Tag internals) =
    internals.watched


mapWatched : (Bool -> Bool) -> Tag -> Tag
mapWatched transform (Tag internals) =
    Tag { internals | watched = transform internals.watched }



{- Util -}


toSource : msg -> List Tag -> Source msg
toSource msg tags =
    Search.source
        (List.map
            (\(Tag t) ->
                t.name
            )
            tags
        )
        "tag"
        msg



{- JSON -}


decoder : Decoder Tag
decoder =
    Decode.succeed Internals
        |> required "name" Decode.string
        |> required "description" Decode.string
        |> optional "watched" Decode.bool True
        |> Decode.map Tag


encode : Tag -> Value
encode (Tag tag) =
    Encode.object
        [ ( "name", Encode.string tag.name )
        , ( "description", Encode.string tag.description )
        , ( "watched", Encode.bool tag.watched )
        ]



{- Mock Data -}


mocks : List Tag
mocks =
    [ Tag
        { name = "elm"
        , description = "The elm programming language"
        , watched = True
        }
    , Tag
        { name = "js"
        , description = "The Javascript programming language"
        , watched = True
        }
    , Tag
        { name = "privacy"
        , description = "A well thought out description :P"
        , watched = True
        }
    ]
