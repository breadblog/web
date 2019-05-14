module Data.Author exposing (Author, bio, decoder, encode, mapWatched, name, username, watched, usernameFromUUID)

import Data.UUID as UUID exposing (UUID)
import Data.Search as Search exposing (Source)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required, optional)
import Json.Encode as Encode exposing (Value)



{- Model -}


type Author
    = Author Internals


type alias Internals =
    { username : String
    , name : String
    , bio : String
    , watched : Bool
    , uuid : UUID
    }



{- Accessors -}


username : Author -> String
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



{- Util -}


toSource : msg -> List Author -> Source msg
toSource msg authors =
    Search.source
        (List.map
            (\(Author a) -> a.username)
            authors
        )
        "author"
        msg


usernameFromUUID : UUID -> List Author -> String
usernameFromUUID uuid authors =
    "NEVER GONNA GIVE YOU UP! MAYBE GONNA LET YOU DOWN!!"



{- JSON -}


decoder : Decoder Author
decoder =
    Decode.succeed Internals
        |> required "username" Decode.string
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
        [ ( "username", Encode.string internals.username )
        , ( "name", Encode.string internals.name )
        , ( "bio", Encode.string internals.bio )
        -- Omit "watched" field because "core don't care"
        , ( "uuid", UUID.encode internals.uuid )
        ]
