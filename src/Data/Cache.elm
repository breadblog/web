module Data.Cache exposing (Cache, encode, decoder)


import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Data.Version as Version exposing (Version)
import Data.Theme as Theme exposing (Theme)


type Cache =
    Cache Internals


type alias Internals =
    { version : Version
    , theme : Theme
    }


type Problem =
    CorruptCache


-- JSON


encode : Cache -> Value
encode (Cache cache) =
    Encode.object
        [ ( "version", Version.encode cache.version )
        , ( "theme", Theme.encode cache.theme )
        ]


decoder : Decoder Cache
decoder =
    Decode.succeed Internals
        |> required "version" Version.decoder
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
