module Data.Mode exposing (Mode(..), decoder)


import Json.Decode as Decode exposing (Decoder)


type Mode
    = Development
    | Production


decoder : Decoder Mode
decoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "development" ->
                        Decode.succeed Development

                    "production" ->
                        Decode.succeed Production

                    somethingElse ->
                        Decode.fail ("unknown mode: " ++ somethingElse)
            )
