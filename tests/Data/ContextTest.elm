module Data.ContextTest exposing (suite)

import Data.Context as Context
import Data.Version as Version
import Expect
import Json.Decode as Decode
import Json.Encode as Encode
import Test exposing (..)


suite : Test
suite =
    describe "the Data.Context module"
        [ describe "Context.init"
            [ test "fails with invalid JSON" <|
                \_ ->
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
                                , ( "fullscreen", Encode.bool False )
                                ]
                    in
                    case Version.fromString "0.0.1" of
                        Just currentVersion ->
                            case Decode.decodeValue (Context.flagsDecoder currentVersion) json of
                                Ok _ ->
                                    Expect.fail "should fail to parse"

                                Err _ ->
                                    Expect.pass

                        Nothing ->
                            Expect.fail "invalid version"
            , test "succeeds with valid JSON" <|
                \_ ->
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
                                , ( "fullscreen", Encode.bool False )
                                ]
                    in
                    case Version.fromString "0.0.1" of
                        Just currentVersion ->
                            case Decode.decodeValue (Context.flagsDecoder currentVersion) json of
                                Ok _ ->
                                    Expect.pass

                                Err _ ->
                                    Expect.fail "should decode value successfully"

                        Nothing ->
                            Expect.fail "invalid version"
            ]
        ]
