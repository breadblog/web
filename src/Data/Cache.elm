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


type alias CacheFlags =
    { cache : Internals }



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


init : Value -> Result ( Cache, ProblemPage ) ( Cache, Cmd msg )
init flags =
    case Version.current of
        Just currentVersion ->
            case Decode.decodeValue (flagsDecoder currentVersion) flags of
                Ok internals ->
                    let
                        cache =
                            Cache internals
                    in
                    Ok ( cache, set cache )

                Err err ->
                    Err ( Cache <| default currentVersion, CorruptCache err )

        Nothing ->
            Err <|
                ( Cache <| default Data.Version.error, InvalidVersion )


default : Version -> Internals
default ver =
    { theme = Dark
    , version = ver
    }



-- JSON


flagsDecoder : Version -> Decoder Internals
flagsDecoder currentVersion =
    Decode.succeed CacheFlags
        |> required "cache" (Decode.oneOf [ decoder, defaultDecoder currentVersion ])
        |> Decode.map .cache


decoder : Decoder Internals
decoder =
    Decode.succeed Internals
        |> required "version" Data.Version.decoder
        |> required "theme" Theme.decoder


defaultDecoder : Version -> Decoder Internals
defaultDecoder currentVersion =
    Decode.null (default currentVersion)


encode : Cache -> Value
encode (Cache cache) =
    Encode.object
        [ ( "version", Data.Version.encode cache.version )
        , ( "theme", Theme.encode cache.theme )
        ]
