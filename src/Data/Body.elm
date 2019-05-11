module Data.Body exposing (Body, decoder, encode, fromString, toString)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)



{- Model -}


type Body
    = Body String



{- Accessors -}


toString : Body -> String
toString (Body str) =
    str



{- JSON -}


decoder : Decoder Body
decoder =
    Decode.string
        |> Decode.andThen
            (\str -> Decode.succeed (Body str))


encode : Body -> Value
encode (Body str) =
    Encode.string str



{- TODO: remove. Mock Data -}


fromString : String -> Body
fromString str =
    Body str
