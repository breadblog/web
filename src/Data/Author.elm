module Data.Author exposing (Author, bio, compare, decoder, encode, fromUUID, name, toSources, username, uuid)

import Data.Search as Search exposing (Source)
import Data.UUID as UUID exposing (UUID)
import Data.Username as Username exposing (Username)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode exposing (Value)
import List.Extra
import Util



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
name =
    toInternals >> .name


bio : Author -> String
bio =
    toInternals >> .bio


uuid : Author -> UUID
uuid =
    toInternals >> .uuid


description : Author -> String
description =
    \a -> "Placeholder description"


toInternals : Author -> Internals
toInternals (Author internals) =
    internals



{- Util -}


toSources : msg -> List Author -> List (Source msg)
toSources msg authors =
    List.map (toSource msg) authors


toSource : msg -> Author -> Source msg
toSource msg author =
    Search.source
        { category = "author"
        , onClick = msg
        , name =
            author
                |> username
                |> Username.toString
        , values =
            [ author
                |> username
                |> Username.toString
            , name author
            ]
        , description = description author
        }


fromUUID : UUID -> List Author -> Maybe Author
fromUUID authorUUID list =
    List.Extra.find
        (\a ->
            a
                |> uuid
                |> UUID.compare authorUUID
        )
        list


compare : Author -> Author -> Bool
compare (Author a) (Author b) =
    a.uuid == b.uuid



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
