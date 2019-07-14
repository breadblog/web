module Data.Tag exposing (Tag, compare, decoder, encode, find, mapWatched, mergeFromApi, name, toSource, watched)

import Data.Search as Search exposing (Source)
import Data.UUID as UUID exposing (UUID)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode exposing (Value)
import List.Extra



{- Model -}


type Tag
    = Tag Internals


type alias Internals =
    { name : String
    , description : String
    , watched : Bool
    , uuid : UUID
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


find : UUID -> List Tag -> Maybe Tag
find tagUUID list =
    List.Extra.find
        (\(Tag t) ->
            t
                |> .uuid
                |> UUID.compare tagUUID
        )
        list


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


compare : Tag -> Tag -> Bool
compare (Tag a) (Tag b) =
    a.uuid == b.uuid


mergeFromApi : Tag -> Tag -> Tag
mergeFromApi (Tag fromApi) (Tag fromCache) =
    Tag { fromApi | watched = fromCache.watched }



{- JSON -}


decoder : Decoder Tag
decoder =
    Decode.succeed Internals
        |> required "name" Decode.string
        |> required "description" Decode.string
        |> optional "watched" Decode.bool True
        |> required "uuid" UUID.decoder
        |> Decode.map Tag


encode : Tag -> Value
encode (Tag tag) =
    Encode.object
        [ ( "name", Encode.string tag.name )
        , ( "description", Encode.string tag.description )
        , ( "watched", Encode.bool tag.watched )
        , ( "uuid", UUID.encode tag.uuid )
        ]
