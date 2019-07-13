module Data.Author exposing (Author, bio, compare, decoder, encode, fromUUID, mapWatched, mergeFromApi, name, username, uuid, watched)

import Data.Search as Search exposing (Source)
import Data.UUID as UUID exposing (UUID)
import Data.Username as Username exposing (Username)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode exposing (Value)
import Util



{- Model -}


type Author
    = Author Internals


type alias Internals =
    { username : Username
    , name : String
    , bio : String
    , watched : Bool
    , uuid : UUID
    }



{- Accessors -}


username : Author -> Username
username (Author internals) =
    internals.username


mapWatched : (Bool -> Bool) -> Author -> Author
mapWatched transform (Author internals) =
    Author { internals | watched = transform internals.watched }


watched : Author -> Bool
watched (Author internals) =
    internals.watched


name : Author -> String
name (Author internals) =
    internals.name


bio : Author -> String
bio (Author internals) =
    internals.bio


uuid : Author -> UUID
uuid (Author internals) =
    internals.uuid



{- Util -}


toSource : msg -> List Author -> Source msg
toSource msg authors =
    Search.source
        (List.map
            (\(Author a) ->
                a
                    |> .username
                    |> Username.toString
            )
            authors
        )
        "author"
        msg


fromUUID : UUID -> List Author -> Maybe Author
fromUUID authorUUID list =
    Util.find
        (\a ->
            a
                |> uuid
                |> UUID.compare authorUUID
        )
        list


compare : Author -> Author -> Bool
compare (Author a) (Author b) =
    a.uuid == b.uuid


mergeFromApi : Author -> Author -> Author
mergeFromApi (Author a) (Author b) =
    Author { a | watched = b.watched }



{- JSON -}


decoder : Decoder Author
decoder =
    Decode.succeed Internals
        |> required "username" Username.decoder
        |> required "name" Decode.string
        |> required "bio" Decode.string
        -- Default "watched" because core doesn't provide
        -- don't hardcode because need to decode from cache
        |> optional "watched" Decode.bool True
        |> required "uuid" UUID.decoder
        |> Decode.map Author


encode : Author -> Value
encode (Author internals) =
    Encode.object
        [ ( "username", Username.encode internals.username )
        , ( "name", Encode.string internals.name )
        , ( "bio", Encode.string internals.bio )
        , ( "watched", Encode.bool internals.watched )
        , ( "uuid", UUID.encode internals.uuid )
        ]
