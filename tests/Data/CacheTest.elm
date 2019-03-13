module Data.CacheTest exposing (suite)

import Data.Cache as Cache
import Data.Version exposing (Version)
import Expect
import Json.Encode as Encode
import Test exposing (..)


suite : Test
suite =
    describe "the Data.Cache module"
        [ describe "Cache.init"
            [ test "fails with invalid JSON" <|
                \n ->
                    let
                        json =
                            Encode.object
                                [ ( "cache"
                                  , Encode.object
                                        [ ( "version", Encode.int 29 )
                                        , ( "theme", Encode.string "light" )
                                        ]
                                  )
                                ]
                    in
                    case Cache.init json of
                        Ok _ ->
                            Expect.fail "should fail to parse"

                        Err _ ->
                            Expect.pass
            , test "succeeds with valid JSON" <|
                \n ->
                    let
                        json =
                            Encode.object
                                [ ( "cache"
                                  , Encode.object
                                        [ ( "version", Encode.string "1.2.3" )
                                        , ( "theme", Encode.string "dark" )
                                        ]
                                  )
                                ]
                    in
                    case Cache.init json of
                        Ok _ ->
                            Expect.pass

                        Err _ ->
                            Expect.fail "expected to successfully parse"
            ]
        ]
