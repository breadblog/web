module Example exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)


suite : Test
suite =
    describe "the String module"
        [ describe "String.reverse"
            [ test "has no effect on palindrome" <|
                \n ->
                    let
                        palindrome =
                            "racecar"
                    in
                    Expect.equal palindrome (String.reverse palindrome)
            ]
        ]
