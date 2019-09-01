module Data.Tag exposing (Tag, compare, decoder, encode, find, mergeFromApi, name, toSources)

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
    , uuid : UUID
    }



{- Accessors -}


name : Tag -> String
name =
    toInternals >> .name


description : Tag -> String
description =
    toInternals >> .description


toInternals : Tag -> Internals
toInternals (Tag internals) =
    internals



{- Util -}


mergeFromApi : { old : Tag, fresh : Tag } -> Tag
mergeFromApi { old, fresh } =
    fresh


find : UUID -> List Tag -> Maybe Tag
find tagUUID list =
    List.Extra.find
        (\(Tag t) ->
            t
                |> .uuid
                |> UUID.compare tagUUID
        )
        list


toSources : msg -> List Tag -> List (Source msg)
toSources msg tags =
    List.map (toSource msg) tags


toSource : msg -> Tag -> Source msg
toSource msg tag =
    Search.source
        { category = "tag"
        , onClick = msg
        , name = name tag
        , values =
            [ name tag
            , description tag
            ]
        , description = description tag
        }


compare : Tag -> Tag -> Bool
compare (Tag a) (Tag b) =
    a.uuid == b.uuid



{- JSON -}


decoder : Decoder Tag
decoder =
    Decode.succeed Internals
        |> required "name" Decode.string
        |> required "description" Decode.string
        |> required "uuid" UUID.decoder
        |> Decode.map Tag


encode : Tag -> Value
encode (Tag tag) =
    Encode.object
        [ ( "name", Encode.string tag.name )
        , ( "description", Encode.string tag.description )
        , ( "uuid", UUID.encode tag.uuid )
        ]
