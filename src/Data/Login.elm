module Data.Login exposing (Request, Response, decodeResponse, encodeRequest)

import Data.Password as Password exposing (Password)
import Data.UUID as UUID exposing (UUID)
import Data.Username as Username exposing (Username)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)


type alias Request =
    { username : Username
    , password : Password
    }


type alias Response =
    { uuid : UUID
    }



{- JSON -}


encodeRequest : Request -> Value
encodeRequest request =
    Encode.object
        [ ( "username", Username.encode request.username )
        , ( "password", Password.encode request.password )
        ]


decodeResponse : Decoder Response
decodeResponse =
    Decode.succeed Response
        |> required "uuid" UUID.decoder
