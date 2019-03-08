module Data.Version exposing (Version, Problem, encode, decoder)


import Array
import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder)


type alias Version =
    { major : Int
    , minor : Int
    , patch : Int
    }


type Problem
    = FailedToParse


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
                case (first, second, third) of
                    (Just (Just major), Just (Just minor), Just (Just patch)) ->
                        Just (Version major minor patch)

                    (_, _, _) ->
                        Nothing

            _ ->
                Nothing


-- JSON

encode : Version -> Value
encode version =
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
            |> Encode.string


decoder : Decoder Version
decoder =
    Decode.string
        |> Decode.andThen (\str ->
            case (fromString str) of
                Just version ->
                    Decode.succeed version

                Nothing ->
                    Decode.fail "failed to parse version"
        )



-- TODO: Delete or use
-- module Data.Version exposing (Version(..), encode, decoder)


-- import Json.Encode as Encode exposing (Value)
-- import Json.Decode as Decode exposing (Decoder)


-- type Version = Version String


-- encode : Version -> Value
-- encode (Version version) =
--     Encode.string version


-- decoder : Decoder Version
-- decoder =
--     Decode.string |> Decode.andThen (\str -> Decode.succeed (Version str))
