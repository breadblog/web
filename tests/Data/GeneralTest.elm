module Data.GeneralTest exposing (suite)

import Data.General as General
import Data.Version as Version exposing (Version)
import Expect
import Json.Decode as Decode
import Json.Encode as Encode
import Test exposing (..)


suite : Test
suite =
    describe "the Data.General module"
        [ describe "General.init"
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
                                , ( "mode", Encode.string "production" )
                                , ( "network", Encode.bool True )
                                ]
                    in
                    case Version.fromString "0.0.1" of
                        Just currentVersion ->
                            case Decode.decodeValue (General.flagsDecoder currentVersion) json of
                                Ok _ ->
                                    Expect.fail "should fail to parse"

                                Err _ ->
                                    Expect.pass

                        Nothing ->
                            Expect.fail "invalid version"
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
                                , ( "mode", Encode.string "production" )
                                , ( "network", Encode.bool True )
                                ]
                    in
                    case Version.fromString "0.0.1" of
                        Just currentVersion ->
                            case Decode.decodeValue (General.flagsDecoder currentVersion) json of
                                Ok _ ->
                                    Expect.pass

                                Err _ ->
                                    Expect.fail "should decode value successfully"

                        Nothing ->
                            Expect.fail "invalid version"
            ]
        ]
