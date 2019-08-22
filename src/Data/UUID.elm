{--
    
    Because the web client does not (at time of writing this) create UUID's
    for anything, this is just a simple utility to support the decoding and
    encoding of UUID's without any validation or constructors. It should be expected that
    the server will send valid UUID's to the client, so both creation and validation should
    be unecessary

    NOTE: SHOULD NEVER CREATE UUID's FOR DATABASE ON WEB CLIENT

--}


module Data.UUID exposing (UUID, compare, decoder, encode, missingAuthor, missingTag, toPath, urlParser)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Url.Parser exposing (Parser)



{- Model -}


type UUID
    = UUID String



{- Constructors -}


missingTag : UUID
missingTag =
    UUID "ada1e29b-ac81-4fe3-a9d0-7ca0c55ca592"


missingAuthor : UUID
missingAuthor =
    UUID "21db3896-c32c-4c63-8d45-b811f4757ca9"



{- Util -}


compare : UUID -> UUID -> Bool
compare (UUID a) (UUID b) =
    a == b



{- URL -}


urlParser : Parser (UUID -> a) a
urlParser =
    Url.Parser.custom "UUID" (\str -> Just (UUID str))


toPath : String -> UUID -> String
toPath str (UUID uuid) =
    str ++ "/" ++ uuid



{- JSON -}


decoder : Decoder UUID
decoder =
    Decode.string
        |> Decode.andThen
            (\str -> Decode.succeed (UUID str))


encode : UUID -> Value
encode (UUID str) =
    Encode.string str
