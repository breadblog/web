module Data.Tag exposing (Tag, fetch, compare, decoder, encode, find, getName, getUUID, toSource)

import Data.Search as Search exposing (Source)
import Data.UUID as UUID exposing (UUID)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)
import List.Extra
import Platform exposing (Task)
import Action exposing (Action)
import Http
import Data.Mode exposing (Mode)



{- Model -}


type Tag
    = Tag Internals


type alias Internals =
    { name : String
    , description : String
    , uuid : UUID
    }



{- Accessors -}


getName : Tag -> String
getName (Tag internals) =
    internals.name


getUUID : Tag -> UUID
getUUID (Tag internals) =
    internals.uuid



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



{- HTTP -}


fetch : Mode -> Action -> Task Http.Error Tag
fetch mode endpoint =
    Action.get { endpoint = endpoint, decoder = decoder, mode = mode }



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
