module Data.Username exposing (Username, toString, decoder, encode, compare, fromString)


import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder)


{- Model -}


type Username =
    Username String


{- Accessors -}


toString : Username -> String
toString (Username str) =
    str


{- Util -}

compare : Username -> Username -> Bool
compare (Username a) (Username b) =
    a == b



{- JSON -}


decoder : Decoder Username
decoder =
    Decode.string
        |> Decode.andThen
            (\str -> Decode.succeed (Username str))



encode : Username -> Value
encode (Username str) =
    Encode.string str


{- TODO: Remove. Mock Data -}


fromString : String -> Username
fromString str =
    Username str
