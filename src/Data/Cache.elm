module Data.Cache exposing (Cache, encode, decoder, version, theme, init)


import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Data.Version exposing (Version)
import Data.Theme as Theme exposing (Theme(..))
import Version


type Cache =
    Cache Internals


type alias Internals =
    { version : Version
    , theme : Theme
    }


type Problem
    = CorruptCache
    | BadVersion


-- READONLY


version : Cache -> Version
version (Cache cache) =
    cache.version


-- READWRITE

theme : Cache -> Theme
theme (Cache cache) =
    cache.theme


mapTheme : (Theme -> Theme) -> Cache -> Cache
mapTheme fn (Cache cache) =
    Cache
        { cache | theme = fn cache.theme }


-- Util

init : Result Problem Cache
init =
    case Version.current of
        Just v ->
            Ok
                ( Cache
                    { version = v
                    , theme = Dark
                    }
                )

        Nothing ->
            Err BadVersion


-- JSON


encode : Cache -> Value
encode (Cache cache) =
    Encode.object
        [ ( "version", Data.Version.encode cache.version )
        , ( "theme", Theme.encode cache.theme )
        ]


decoder : Decoder Cache
decoder =
    Decode.succeed Internals
        |> required "version" Data.Version.decoder
        |> required "theme" Theme.decoder
        |> Decode.map Cache


-- Migrations


{-
    How to perform migrations?

    * Separate branch to start working on this
    * Start by getting the version
    * Then we know what parser to use
    * We then run it through all the parsers previous

    Consider using solution in JSON.Decode to try multiple decoders?
-}
