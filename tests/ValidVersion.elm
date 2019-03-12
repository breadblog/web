module ValidVersion exposing (suite)


import Expect
import Test exposing (..)
import Version
import Data.Version exposing (Version)


suite : Test
suite =
    describe "the Version module"
        [ describe "Version.current"
            [ test "returns a valid version"
                <| \n ->
                    case Version.current of
                        Nothing ->
                            Expect.fail ""

                        Just v ->
                            Expect.pass
            ]
        ]
