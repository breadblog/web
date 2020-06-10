module Data.Author exposing (Author, bio, compare, decoder, encode, show, index, fromUUID, getUUID, name, username)

import Data.Mode as Mode exposing (Mode)
import Data.Search as Search exposing (Source)
import Data.UUID as UUID exposing (UUID)
import Data.Username as Username exposing (Username)
import Endpoint exposing (Endpoint)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode exposing (Value)
import List.Extra
import Platform exposing (Task)



{- Model -}


type Author
    = Author Internals


type alias Internals =
    { username : Username
    , name : String
    , bio : String
    , uuid : UUID
    }



{- Accessors -}


username : Author -> Username
username (Author internals) =
    internals.username


name : Author -> String
name (Author internals) =
    internals.name


bio : Author -> String
bio (Author internals) =
    internals.bio


getUUID : Author -> UUID
getUUID (Author internals) =
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
    List.Extra.find
        (\a ->
            a
                |> getUUID
                |> UUID.compare authorUUID
        )
        list


compare : Author -> Author -> Bool
compare (Author a) (Author b) =
    a.uuid == b.uuid



{- Http -}


show : Mode -> Endpoint -> Task Http.Error Author
show mode endpoint =
    Endpoint.get { decoder = decoder, endpoint = endpoint, mode = mode }


index : Mode -> Endpoint -> Task Http.Error (List Author)
index mode endpoint =
    Endpoint.get { decoder = Decode.list decoder, endpoint = endpoint, mode = mode }



{- JSON -}


decoder : Decoder Author
decoder =
    Decode.succeed Internals
        |> required "username" Username.decoder
        |> required "name" Decode.string
        |> required "bio" Decode.string
        |> required "uuid" UUID.decoder
        |> Decode.map Author


encode : Author -> Value
encode (Author internals) =
    Encode.object
        [ ( "username", Username.encode internals.username )
        , ( "name", Encode.string internals.name )
        , ( "bio", Encode.string internals.bio )
        , ( "uuid", UUID.encode internals.uuid )
        ]
