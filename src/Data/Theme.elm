module Data.Theme exposing (Theme(..), encode, decoder, toString)


import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type Theme
    = Dark
    | Light


toString : Theme -> String
toString theme =
    case theme of
        Dark -> "dark"

        Light -> "light"


-- JSON


encode : Theme -> Value
encode theme =
    theme
        |> toString
        |> Encode.string


-- TODO: How to handle fail case?
decoder : Decoder Theme
decoder =
    Decode.string
        |> Decode.andThen (\str ->
            case str of
                "light" -> Decode.succeed Light
                "dark" -> Decode.succeed Dark
                somethingElse -> Decode.fail ("unknown theme " ++ somethingElse)
        )
