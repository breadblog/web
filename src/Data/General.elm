port module Data.General exposing (General, Msg(..), authors, flagsDecoder, init, key, problems, pushProblem, tags, theme, update, updateAuthors, version, host)

import Browser.Navigation exposing (Key)
import Data.Author as Author exposing (Author)
import Data.Markdown as Markdown
import Data.Problem as Problem exposing (Description(..), Problem)
import Data.Tag as Tag exposing (Tag)
import Data.Theme as Theme exposing (Theme(..))
import Data.Version exposing (Version)
import Data.Mode as Mode exposing (Mode(..))
import Data.Config exposing (Config)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode exposing (Value)
import Version
import Api exposing (Host, Url)



{- Model -}


type General
    = General IGeneral


type alias Flags =
    { mode : Mode
    , cache : Cache
    }


type alias IGeneral =
    { cache : Cache
    , user : Maybe Author
    , key : Key
    , problems : List (Problem Msg)
    , config : Config
    }


type Cache
    = Cache ICache


type alias ICache =
    { version : Version
    , theme : Theme
    , tags : List Tag
    , authors : List Author
    }




{- Constructors -}


init : Key -> Value -> ( General, Cmd Msg )
init key_ flags =
    let
        ( decoded, cacheProblems ) =
            case Version.current of
                Just currentVersion ->
                    case Decode.decodeValue (flagsDecoder currentVersion) flags of
                        Ok d ->
                            ( d, [] )

                        Err err ->
                            ( defaultFlags currentVersion
                            , [ Problem.create
                                "Corrupt flags"
                                (JsonError err)
                                Nothing
                              ]
                            )

                Nothing ->
                    let
                        errorMsg =
                            """
                            The current version of the application is invalid. This error is safe to ignore, although we'd appreciate if you open an issue.
                            """
                    in
                    ( defaultFlags Data.Version.error
                    , [ Problem.create
                            "Invalid Version"
                            (MarkdownError <| Markdown.create errorMsg)
                            Nothing
                      ]
                    )

        general =
            { cache = decoded.cache
            , user = Nothing
            , key = key_
            , problems = cacheProblems
            , config = initConfig decoded
            }
                |> General
    in
    ( general, setCache decoded.cache )


defaultCache : Version -> Cache
defaultCache currentVersion =
    { theme = Dark
    , version = currentVersion
    , tags = []
    , authors = []
    }
        |> Cache


defaultFlags : Version -> Flags
defaultFlags version_ =
    { cache = defaultCache version_
    , mode = Production
    }


initConfig : Flags -> Config
initConfig flags =
    let
        host_ =
            Api.hostFromMode flags.mode

    in
    { host = host_
    }



{- Messages -}


type Msg
    = SetTheme Theme
    | ToggleTag Tag
    | ToggleAuthor Author
    | UpdateAuthors
    | GotAuthors (Result Http.Error (List Author))



{- Update -}


update : Msg -> General -> ( General, Cmd Msg )
update msg general =
    let
        (Cache iCache) =
            cache general

        (General iGeneral) =
            general

        ( newGeneral, commands ) =
            case msg of
                SetTheme theme_ ->
                    updateCache general { iCache | theme = theme_ }

                ToggleTag tag ->
                    let
                        tags_ =
                            toggleTagList tag iCache.tags
                    in
                    updateCache general { iCache | tags = tags_ }

                ToggleAuthor author ->
                    let
                        authors_ =
                            toggleAuthorList author iCache.authors
                    in
                    updateCache general { iCache | authors = authors_ }

                UpdateAuthors ->
                    ( general, [ updateAuthors general ] )

                GotAuthors res ->
                    case res of
                        Ok authors_ ->
                            updateCache general { iCache | authors = authors_ }

                        Err err ->
                            let
                                problem =
                                    Problem.create
                                        "Failed to Update Authors"
                                        (HttpError err)
                                        Nothing
                            in
                            ( { iGeneral
                                | problems = problem :: iGeneral.problems
                              }
                                |> General
                            , [ Cmd.none ]
                            )
    in
    ( newGeneral
    , Cmd.batch <|
        commands
            ++ [ setCache <| cache newGeneral ]
    )


updateCache : General -> ICache -> ( General, List (Cmd Msg) )
updateCache general iCache =
    let
        (General iGeneral) =
            general

        cache_ =
            Cache iCache
    in
    ( General { iGeneral | cache = cache_ }
    , [ setCache <| cache_ ]
    )


toggleTagList : Tag -> List Tag -> List Tag
toggleTagList tag =
    let
        toggled =
            Tag.mapWatched (\n -> not n) tag
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
            Author.mapWatched not author
    in
    List.map
        (\a ->
            if a == author then
                toggled

            else
                a
        )



{- HTTP -}


updateAuthors : General -> Cmd Msg
updateAuthors (General general) =
    Api.get
        { url = Api.url general.config.host "author"
        , expect = Http.expectJson GotAuthors (Decode.list Author.decoder)
        }



{- Ports -}


port setCachePort : Value -> Cmd msg


setCache : Cache -> Cmd msg
setCache c =
    c
        |> encodeCache
        |> setCachePort



{- Accessors (public) -}


cache : General -> Cache
cache (General internals) =
    internals.cache


version : General -> Version
version general =
    general
        |> cache
        |> cacheInternals
        |> .version


theme : General -> Theme
theme general =
    general
        |> cache
        |> cacheInternals
        |> .theme


tags : General -> List Tag
tags general =
    general
        |> cache
        |> cacheInternals
        |> .tags


authors : General -> List Author
authors general =
    general
        |> cache
        |> cacheInternals
        |> .authors



-- TODO: Change to User type


user : General -> Maybe Author
user (General general) =
    general.user


problems : General -> List (Problem Msg)
problems (General general) =
    general.problems


pushProblem : Problem Msg -> General -> General
pushProblem problem (General general) =
    { general | problems = problem :: general.problems }
        |> General


key : General -> Key
key (General internals) =
    internals.key


host : General -> Host
host (General internals) =
    internals.config.host



{- Accessors (private) -}


cacheInternals : Cache -> ICache
cacheInternals (Cache iCache) =
    iCache



{- JSON -}


flagsDecoder : Version -> Decoder Flags
flagsDecoder currentVersion =
    Decode.succeed Flags
        |> required "mode" Mode.decoder
        |> required "cache" (Decode.oneOf [ cacheDecoder, defaultCacheDecoder currentVersion ])




cacheDecoder : Decoder Cache
cacheDecoder =
    Decode.succeed ICache
        |> required "version" Data.Version.decoder
        |> required "theme" Theme.decoder
        |> optional "tags"
            (Decode.list Tag.decoder)
            []
        |> optional "authors"
            (Decode.list Author.decoder)
            []
        |> Decode.map Cache


defaultCacheDecoder : Version -> Decoder Cache
defaultCacheDecoder currentVersion =
    Decode.null (defaultCache currentVersion)


encodeCache : Cache -> Value
encodeCache (Cache c) =
    Encode.object
        [ ( "version", Data.Version.encode c.version )
        , ( "theme", Theme.encode c.theme )
        , ( "tags", Encode.list Tag.encode c.tags )
        , ( "authors", Encode.list Author.encode c.authors )
        ]
