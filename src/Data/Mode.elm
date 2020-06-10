module Data.Mode exposing (Env(..), Mode, decoder, default, toEnv, toUrl)

import Json.Decode as Decode exposing (Decoder)
import Url exposing (Url)


type Mode
    = Mode Internals


type alias Internals =
    { env : Env
    , url : Url
    }


type Env
    = Prod
    | Dev


default : Mode
default =
    Mode { url = prodUrl, env = Prod }


prodUrl : Url
prodUrl =
    { protocol = Url.Https
    , host = "blog-api.parasrah.com"
    , port_ = Just 9443
    , path = "/"
    , query = Nothing
    , fragment = Nothing
    }


devUrl : Url
devUrl =
    { protocol = Url.Http
    , host = "127.0.0.1"
    , port_ = Just 4000
    , path = ""
    , query = Nothing
    , fragment = Nothing
    }


decoder : Decoder Mode
decoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                let
                    maybeEnv =
                        case str of
                            "development" ->
                                Just Dev

                            "production" ->
                                Just Prod

                            _ ->
                                Nothing
                in
                case maybeEnv of
                    Just env ->
                        let
                            url =
                                case env of
                                    Dev ->
                                        devUrl

                                    Prod ->
                                        prodUrl
                        in
                        Decode.succeed <| Mode { url = url, env = env }

                    _ ->
                        Decode.fail "failed to parse mode"
            )


toUrl : Mode -> Url
toUrl (Mode { url }) =
    url


toEnv : Mode -> Env
toEnv (Mode { env }) =
    env
