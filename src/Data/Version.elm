module Data.Version exposing (Version, fromString, Error)


import Array


type alias Version =
    { major : Int
    , minor : Int
    , patch : Int
    }


type Error
    = FailedToParse


fromString : String -> Result Version Error
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
                    (Just major, Just minor, Just patch) ->
                        Ok(
                            { major = major
                            , minor = minor
                            , patch = patch
                            }
                        )
            _ ->
                Err(FailedToParse)

            _ ->
                Err(FailedToParse)

