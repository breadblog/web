module Data.Body exposing (Body, decoder, encode, fromString, toString)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Data.Markdown as Markdown exposing (Markdown)



{- Model -}


type Body
    = Body Markdown



{- Accessors -}




{- JSON -}


decoder : Decoder Body
decoder =
    Markdown.decoder
        |> Decode.andThen
            (\md -> Decode.succeed (Body md))


encode : Body -> Value
encode (Body str) =
    Encode.string str
