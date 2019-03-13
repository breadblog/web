module Data.CacheTest exposing (suite)

import Data.Version exposing (Version)
import Expect
import Test exposing (..)
import Data.Cache as Cache
import Json.Encode as Encode


suite : Test
suite =
    describe "the Data.Cache module"
        [ describe "Cache.init"
            [ test "fails with invalid JSON" <|
                \n ->
                    let
                        json =
                            Encode.string
                                """
                                {
                                    "version": 29,
                                    "theme": "dark"
                                }
                                """

                    in
                    case Cache.init json of
                        Ok _ ->
                            Expect.fail "should fail to parse"

                        Err _ ->
                            Expect.pass
            , test "succeeds with valid JSON" <|
                \n ->
                    let json =
                            Encode.string
                                """
                                {
                                    "version": "1.2.4",
                                    "theme": "dark"
                                }
                                """

                    in
                    case Cache.init json of
                        Ok _ ->
                            Expect.pass

                        Err _ ->
                            Expect.fail "expected to successfully parse"
            ]
        ]
