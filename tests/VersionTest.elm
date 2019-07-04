module VersionTest exposing (suite)

import Data.Version exposing (Version)
import Expect
import Test exposing (..)
import Version


suite : Test
suite =
    describe "the Version module"
        [ describe "Version.current"
            [ test "returns a valid version" <|
                \n ->
                    case Version.current of
                        Nothing ->
                            Expect.fail "the current version is invalid"

                        Just v ->
                            Expect.pass
            ]
        ]
