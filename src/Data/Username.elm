module Data.Username exposing (Username, toString, decoder, encode)


import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type Username =
    Username String


toString : Username -> String
toString (Username str) =
    str


decoder : Decoder Username
decoder =
    Decode.string
        |> Decode.andThen
            (\str -> Decode.succeed (Username str))


encode : Username -> Value
encode (Username str) =
    Encode.string str
