module Data.Cache exposing (Cache, decoder, default, encode, init, mapTheme, theme, version)

import Data.Route exposing (ProblemPage(..))
import Data.Theme as Theme exposing (Theme(..))
import Data.Version exposing (Version)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)
import Version


type Cache
    = Cache Internals


type alias Internals =
    { version : Version
    , theme : Theme
    }



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


init : Value -> Result ( Cache, ProblemPage ) Cache
init flags =
    case Decode.decodeValue decoder flags of
        Ok cache ->
            Ok cache

        Err _ ->
            default


default : Result ( Cache, ProblemPage ) Cache
default =
    case Version.current of
        Just v ->
            Ok <|
                Cache <|
                    { version = v
                    , theme = Dark
                    }

        Nothing ->
            Err
                ( Cache
                    { version = Data.Version.error
                    , theme = Dark
                    }
                , InvalidVersion
                )



-- TODO: Turn this into an error page
-- Nothing ->
--     Err
--         ( ProblemInfo.create
--             { title = "Cannot parse version"
--             , description =
--                 """
--                 The current version for the application is invalid
--                 If you are a user seeing this message... I am so sorry. There is no reason this should ever have occurred in production.
--                 I hope you still have a nice day, and hopefully if you check back later this will be fixed. Feel free to send an email to blog@parasrah.com and let me know about this if you want to really go the extra mile. Make sure to include a subject line of "tsk tsk" or something similar
--                 PS: If you are a developer... This is why you always use CI
--                 """
--             , action = Nothing
--             }
--         )
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
