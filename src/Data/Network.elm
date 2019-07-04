module Data.Network exposing (Network(..), decoder)


import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type Network
    = Offline
    | Online


{- JSON -}

decoder : Decoder Network
decoder =
    Decode.bool
        |> Decode.andThen
            (\b ->
                if b then
                    Decode.succeed Online

                else
                    Decode.succeed Offline
            )


encode : Network -> Value
encode network =
    let bool =
            case network of
                Online ->
                    True

                Offline ->
                    False

    in
    Encode.bool bool
