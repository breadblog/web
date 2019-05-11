module Data.Author exposing (Author, bio, decoder, encode, mapWatched, mocks, name, username, watched)

import Data.Search as Search exposing (Source)
import Data.Username as Username exposing (Username)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)



{- Model -}


type Author
    = Author Internals


type alias Internals =
    { username : Username
    , name : String
    , bio : String
    , watched : Bool
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



{- Util -}


toSource : msg -> List Author -> Source msg
toSource msg authors =
    Search.source
        (List.map
            (\(Author a) -> Username.toString a.username)
            authors
        )
        "author"
        msg



{- JSON -}


decoder : Decoder Author
decoder =
    Decode.succeed Internals
        |> required "username" Username.decoder
        |> required "name" Decode.string
        |> required "bio" Decode.string
        |> required "watched" Decode.bool
        |> Decode.map Author


encode : Author -> Value
encode (Author internals) =
    Encode.object
        [ ( "username", Username.encode internals.username )
        , ( "name", Encode.string internals.name )
        , ( "bio", Encode.string internals.bio )
        , ( "watched", Encode.bool internals.watched )
        ]



{- Mock Data -}


mocks : List Author
mocks =
    [ Author
        { username = Username.fromString "parasrah"
        , name = "Brad Pfannmuller"
        , bio = "privacy enthusiast and web developer"
        , watched = True
        }
    , Author
        { username = Username.fromString "qnbst"
        , name = "Bea Esguerra"
        , bio = "food enthusiast and web developer"
        , watched = True
        }
    ]
