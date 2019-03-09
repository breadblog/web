module Data.Version exposing (Version, decoder, encode, error, fromString, toString)

import Array
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


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



-- TODO: Test this


fromString : String -> Maybe Version
fromString str =
    let
        splits =
            String.split "." str

        parsed =
            splits
                |> List.map String.toInt
                |> Array.fromList

        first =
            Array.get 0 parsed

        second =
            Array.get 1 parsed

        third =
            Array.get 2 parsed

        numSplits =
            List.length splits
    in
    case numSplits of
        3 ->
            case ( first, second, third ) of
                ( Just (Just major), Just (Just minor), Just (Just patch) ) ->
                    Just <| Version <| Internals major minor patch

                ( _, _, _ ) ->
                    Nothing

        _ ->
            Nothing



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
