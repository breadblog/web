module Data.Version exposing (Version, decoder, encode, error, fromString, toString)

import Array
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Parser exposing ((|.), (|=), Parser, end, int, symbol)
import Parser.Advanced exposing (chompWhile, getChompedString)


type Version
    = Version Internals


type alias Internals =
    { major : Int
    , minor : Int
    , patch : Int
    }



-- Util


error : Version
error =
    Version <| Internals -1 -1 -1


toString : Version -> String
toString (Version version) =
    let
        list =
            [ version.major
            , version.minor
            , version.patch
            ]
    in
    list
        |> List.map String.fromInt
        |> String.join "."


fromString : String -> Maybe Version
fromString str =
    case Parser.run parser str of
        Err _ ->
            Nothing

        Ok version ->
            Just version


parser : Parser Version
parser =
    Parser.map Version <|
        Parser.succeed Internals
            |= segment
            |. symbol "."
            |= segment
            |. symbol "."
            |= segment
            |. end


segment : Parser Int
segment =
    getChompedString (chompWhile Char.isDigit)
        |> Parser.andThen checkSegment


checkSegment : String -> Parser Int
checkSegment str =
    case String.toInt str of
        Just n ->
            Parser.succeed n

        _ ->
            Parser.problem "version segment is not an integer"



-- JSON


encode : Version -> Value
encode version =
    version
        |> toString
        |> Encode.string


decoder : Decoder Version
decoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case fromString str of
                    Just version ->
                        Decode.succeed version

                    Nothing ->
                        Decode.fail "failed to parse version"
            )
