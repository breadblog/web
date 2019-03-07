module Data.PostId exposing (PostId, encode, decoder)


import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type PostId
    = PostId Int


decoder : Decoder PostId
decoder =
    Decode.string


encode : PostId -> Value
encode (PostId id) =
    Encode.int id
