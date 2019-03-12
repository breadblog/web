port module Data.Cache exposing (Cache, Msg(..), init, theme, update, version)

import Data.Route exposing (ProblemPage(..))
import Data.Theme as Theme exposing (Theme(..))
import Data.Version exposing (Version)
import Json.Decode as Decode exposing (Decoder, Error(..))
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)
import Version


type Cache
    = Cache Internals


type alias Internals =
    { version : Version
    , theme : Theme
    }



-- Message


type Msg
    = SetTheme Theme



-- Update


update : Msg -> Cache -> ( Cache, Cmd msg )
update msg (Cache oldCache) =
    let
        internals =
            case msg of
                SetTheme newTheme ->
                    { oldCache | theme = newTheme }

        newCache =
            Cache internals
    in
    ( newCache, set newCache )



-- Ports


port setCache : Value -> Cmd msg


set : Cache -> Cmd msg
set cache =
    cache
        |> encode
        |> setCache



-- READONLY


version : Cache -> Version
version (Cache cache) =
    cache.version



-- READONLY


theme : Cache -> Theme
theme (Cache cache) =
    cache.theme



-- Util


init : Value -> Result ( Cache, ProblemPage ) Cache
init flags =
    case Version.current of
        Just currentVersion ->
            case Decode.decodeValue decoders flags of
                Ok internals ->
                    Ok <| Cache internals

                Err err ->
                    Err ( Cache <| default currentVersion, CorruptCache err )

        Nothing ->
            Err <|
                ( Cache <| default Data.Version.error, InvalidVersion )


default : Version -> Internals
default ver =
    { theme = Light
    , version = ver
    }



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


defaultDecoder : Version -> Decoder Internals
defaultDecoder currentVersion =
    Decode.null <| default currentVersion


decoders : Decoder Internals
decoders =
    Decode.oneOf
        [ decoder__A
        ]


decoder__A : Decoder Internals
decoder__A =
    Decode.succeed Internals
        |> required "version" Data.Version.decoder
        |> required "theme" Theme.decoder



-- Migrations
{-
   How to perform migrations?

   * Separate branch to start working on this
   * Start by getting the version
   * Then we know what parser to use
   * We then run it through all the parsers previous

   Consider using solution in JSON.Decode to try multiple decoders?
-}
