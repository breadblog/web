module Data.Login exposing (Request, Response, encodeRequest, decodeResponse)

import Data.Password as Password exposing (Password)
import Data.UUID as UUID exposing (UUID)
import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)


type alias Request =
    { username : String
    , password : Password
    }


type alias Response =
    { uuid : UUID
    }



{- JSON -}


encodeRequest : Request -> Value
encodeRequest request =
    Encode.object
        [ ( "username", Encode.string request.username )
        , ( "password", Password.encode request.password )
        ]


decodeResponse : Decoder Response
decodeResponse =
    Decode.succeed Response
        |> required "uuid" UUID.decoder
