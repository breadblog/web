module Data.Theme exposing (Theme(..), encode, decoder)


import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type Theme
    = Dark
    | Light


-- JSON


encode : Theme -> Value
encode theme =
    Encode.string
        <| case theme of
            Light -> "light"

            Dark -> "dark"


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
