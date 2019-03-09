module Data.User exposing (User, decoder, encode)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)


type User
    = User Internals


type alias Internals =
    { username : String
    }


encode : User -> Value
encode (User user) =
    Encode.object
        [ ( "username", Encode.string user.username )
        ]


decoder : Decoder User
decoder =
    Decode.succeed Internals
        |> required "username" Decode.string
        |> Decode.map User
