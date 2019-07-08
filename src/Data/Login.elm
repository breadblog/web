module Data.Login exposing (Request, encode)

import Data.Password as Password exposing (Password)
import Json.Encode as Encode exposing (Value)


type alias Request =
    { username : String
    , password : Password
    }



{- JSON -}


encode : Request -> Value
encode request =
    Encode.object
        [ ( "username", Encode.string request.username )
        , ( "password", Password.encode request.password )
        ]
