module Data.UUID exposing (UUID, decoder, encode, fromString)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)



{--
    
    Because the web client does not (at time of writing this) create UUID's
    for anything, this is just a simple utility to support the decoding and
    encoding of UUID's without any validation or constructors. It should be expected that
    the server will send valid UUID's to the client, so both creation and validation should
    be unecessary

    NOTE: SHOULD NEVER CREATE UUID's FOR DATABASE ON WEB CLIENT

--}
{- Model -}


type UUID
    = UUID String



{- JSON -}


decoder : Decoder UUID
decoder =
    Decode.string
        |> Decode.andThen
            (\str -> Decode.succeed (UUID str))


encode : UUID -> Value
encode (UUID str) =
    Encode.string str



{- TODO: remove. Mock data -}


fromString : String -> UUID
fromString str =
    UUID str
