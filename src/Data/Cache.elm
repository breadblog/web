port module Data.Cache exposing (Cache, Msg(..), authors, init, tags, theme, update, version)

import Data.Author as Author exposing (Author)
import Data.Route exposing (ProblemPage(..))
import Data.Tag as Tag exposing (Tag)
import Data.Theme as Theme exposing (Theme(..))
import Data.Version exposing (Version)
import Json.Decode as Decode exposing (Decoder, Error(..))
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode exposing (Value)
import Version


type Cache
    = Cache Internals


type alias Internals =
    { version : Version
    , theme : Theme
    , tags : List Tag
    , authors : List Author
    }


type alias CacheFlags =
    { cache : Internals }



-- Message


type Msg
    = SetTheme Theme
    | ToggleTag Tag
    | ToggleAuthor Author



-- Update


update : Msg -> Cache -> ( Cache, Cmd msg )
update msg (Cache oldCache) =
    let
        ( internals, cmd ) =
            case msg of
                SetTheme newTheme ->
                    ( { oldCache | theme = newTheme }
                    , Cmd.none
                    )

                ToggleTag tag ->
                    ( { oldCache | tags = toggleTagList tag oldCache.tags }
                    , Cmd.none
                    )

                ToggleAuthor author ->
                    ( { oldCache | authors = toggleAuthorList author oldCache.authors }
                    , Cmd.none
                    )

        newCache =
            Cache internals
    in
    ( newCache
    , Cmd.batch
        [ set newCache
        , cmd
        ]
    )


toggleTagList : Tag -> List Tag -> List Tag
toggleTagList tag =
    let
        toggled =
            Tag.mapValue (\n -> not n) tag
    in
    List.map
        (\t ->
            if t == tag then
                toggled

            else
                t
        )


toggleAuthorList : Author -> List Author -> List Author
toggleAuthorList author =
    let
        toggled =
            Author.mapValue not author
    in
    List.map
        (\a ->
            if a == author then
                toggled

            else
                a
        )



-- Ports


port setCache : Value -> Cmd msg


set : Cache -> Cmd msg
set cache =
    cache
        |> encode
        |> setCache



-- Accessors --
-- version


version : Cache -> Version
version (Cache cache) =
    cache.version



-- theme


theme : Cache -> Theme
theme (Cache cache) =
    cache.theme



-- tags


tags : Cache -> List Tag
tags (Cache cache) =
    cache.tags



-- authors


authors : Cache -> List Author
authors (Cache cache) =
    cache.authors



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
    , tags = []
    , authors = []
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
        |> optional "tags"
            (Decode.list Tag.decoder)
            [ Tag.init "elm"
            , Tag.init "rust"
            , Tag.init "dev"
            , Tag.init "privacy"
            , Tag.init "food"
            , Tag.init "travel"
            , Tag.init "philosophy"
            ]
        |> optional "authors"
            (Decode.list Author.decoder)
            [ Author.init "Parasrah"
            , Author.init "Qnbst"
            ]


defaultDecoder : Version -> Decoder Internals
defaultDecoder currentVersion =
    Decode.null (default currentVersion)


encode : Cache -> Value
encode (Cache cache) =
    Encode.object
        [ ( "version", Data.Version.encode cache.version )
        , ( "theme", Theme.encode cache.theme )
        , ( "tags", Encode.list Tag.encode cache.tags )
        , ( "authors", Encode.list Author.encode cache.authors )
        ]
