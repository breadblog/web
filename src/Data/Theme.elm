module Data.Theme exposing (Theme(..), all, decoder, encode, toString)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type Theme
    = Dark
    | Light


all : List Theme
all =
    [ Dark
    , Light
    ]



-- Util --


toString : Theme -> String
toString theme =
    case theme of
        Dark ->
            "dark"

        Light ->
            "light"



-- JSON --


encode : Theme -> Value
encode theme =
    theme
        |> toString
        |> Encode.string


decoder : Decoder Theme
decoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "light" ->
                        Decode.succeed Light

                    "dark" ->
                        Decode.succeed Dark

                    somethingElse ->
                        Decode.fail ("unknown theme " ++ somethingElse)
            )
