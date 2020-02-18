port module Data.General exposing (General, Msg(..), flagsDecoder, focus, fullscreen, fullscreenSub, init, key, mapUser, mode, networkSub, problems, pushProblem, theme, update, user, version)

import Api exposing (Url)
import Browser.Navigation exposing (Key)
import Data.Config exposing (Config)
import Data.Markdown as Markdown
import Data.Mode as Mode exposing (Mode(..))
import Data.Network as Network exposing (Network(..))
import Data.Problem as Problem exposing (Description(..), Problem)
import Data.Route as Route exposing (Route(..))
import Data.Theme as Theme exposing (Theme(..))
import Data.UUID as UUID exposing (UUID)
import Data.Version exposing (Version)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode exposing (Value)
import List.Extra
import Version



{- Model -}


type General
    = General IGeneral


type alias Flags =
    { mode : Mode
    , cache : Cache
    , network : Network
    , fullscreen : Bool
    }


type alias IGeneral =
    { cache : Cache
    , key : Key
    , problems : List (Problem Msg)
    , config : Config
    , network : Network
    , fullscreen : Bool
    }


type Cache
    = Cache ICache


type alias ICache =
    { version : Version
    , theme : Theme
    , user : Maybe UUID
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
                                    "Corrupt preferences flags"
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
            , key = key_
            , problems = cacheProblems
            , config = initConfig decoded
            , network = decoded.network
            , fullscreen = decoded.fullscreen
            }
                |> General
    in
    ( general
    , Cmd.batch
        [ setCache decoded.cache
        ]
    )


defaultCache : Version -> Cache
defaultCache currentVersion =
    { theme = Dark
    , version = currentVersion
    , user = Nothing
    }
        |> Cache


defaultFlags : Version -> Flags
defaultFlags version_ =
    { cache = defaultCache version_
    , mode = Production
    , network = Offline
    , fullscreen = False
    }


initConfig : Flags -> Config
initConfig flags =
    { mode = flags.mode
    }



{- Messages -}


type Msg
    = SetTheme Theme
    | UpdateNetwork Network
    | NetworkProblem Decode.Error
    | TryLogout
    | OnLogout (Result Http.Error ())
    | NavigateTo Route
    | ReportErr (Problem Msg)
    | DismissProblem Int
    | WithDismiss Int Msg
    | FullscreenElement String
    | ExitFullscreen
    | UpdateFullscreen Bool
    | PushProblem (Problem Msg)
    | GoBack



{- Update -}


update : Msg -> General -> ( General, Cmd Msg )
update msg general =
    let
        (Cache iCache) =
            cache general

        (General internals) =
            general

        ( newGeneral, cmd ) =
            case msg of
                SetTheme theme_ ->
                    updateCache general { iCache | theme = theme_ }

                UpdateNetwork network ->
                    ( General { internals | network = network }
                    , Cmd.none
                    )

                NetworkProblem err ->
                    let
                        problem =
                            Problem.create "Network problem" (JsonError err) Nothing
                    in
                    ( General { internals | problems = problem :: internals.problems }
                    , Cmd.none
                    )

                TryLogout ->
                    ( general, tryLogout general )

                OnLogout res ->
                    case res of
                        Ok _ ->
                            updateCache general { iCache | user = Nothing }

                        Err err ->
                            let
                                problem =
                                    Problem.create
                                        "Failed to logout"
                                        (HttpError err)
                                        Nothing
                            in
                            ( pushProblem problem general
                            , Cmd.none
                            )

                NavigateTo route ->
                    navigateTo route general

                ReportErr _ ->
                    ( general, Cmd.none )

                DismissProblem index ->
                    ( dismissProblem index general, Cmd.none )

                WithDismiss index nestedMsg ->
                    update nestedMsg <| dismissProblem index general

                FullscreenElement class ->
                    ( general, fullscreenElement class )

                ExitFullscreen ->
                    ( general, exitFullscreen () )

                UpdateFullscreen fs ->
                    ( General { internals | fullscreen = fs }
                    , Cmd.none
                    )

                PushProblem problem ->
                    ( pushProblem problem general
                    , Cmd.none
                    )

                GoBack ->
                    ( general
                    , Browser.Navigation.back (key general) 1
                    )
    in
    ( newGeneral
    , Cmd.batch
        [ cmd
        ]
    )


updateCache : General -> ICache -> ( General, Cmd Msg )
updateCache general iCache =
    let
        (General internals) =
            general

        cache_ =
            Cache iCache
    in
    ( General { internals | cache = cache_ }
    , setCache <| cache_
    )


dismissProblem : Int -> General -> General
dismissProblem index (General internals) =
    General { internals | problems = List.Extra.removeAt index internals.problems }


navigateTo : Route -> General -> ( General, Cmd msg )
navigateTo route general =
    ( general
    , Browser.Navigation.pushUrl (key general) (Route.toPath route)
    )


mapCache : Cache -> General -> ( General, Cmd msg )
mapCache cache_ (General general_) =
    ( General { general_ | cache = cache_ }
    , setCache cache_
    )


{- HTTP -}

tryLogout : General -> Cmd Msg
tryLogout general =
    let
        url =
            Api.url (mode general) "/logout/"

        expect =
            Http.expectWhatever OnLogout
    in
    Api.post
        { url = url
        , expect = expect
        , body = Http.emptyBody
        }



{- Ports -}


port focus : String -> Cmd msg


port exitFullscreen : () -> Cmd msg


port fullscreenElement : String -> Cmd msg


port setCachePort : Value -> Cmd msg


setCache : Cache -> Cmd msg
setCache c =
    c
        |> encodeCache
        |> setCachePort


port getNetworkPort : (Value -> msg) -> Sub msg


port getFullscreenPort : (Value -> msg) -> Sub msg


networkSub : Sub Msg
networkSub =
    getNetworkPort
        (\v ->
            case Decode.decodeValue Network.decoder v of
                Ok network ->
                    UpdateNetwork network

                Err err ->
                    NetworkProblem err
        )


fullscreenSub : Sub Msg
fullscreenSub =
    getFullscreenPort
        (\v ->
            case Decode.decodeValue Decode.bool v of
                Ok fs ->
                    UpdateFullscreen fs

                Err err ->
                    PushProblem <|
                        Problem.create
                            "Failed to determine fullscreen state"
                            (JsonError err)
                            Nothing
        )



{- Accessors (public) -}


fullscreen : General -> Bool
fullscreen (General internals) =
    internals.fullscreen


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


user : General -> Maybe UUID
user general =
    general
        |> cache
        |> cacheInternals
        |> .user


mapUser : UUID -> General -> ( General, Cmd msg )
mapUser uuid general =
    let
        (General internals) =
            general

        (Cache iCache) =
            internals.cache
    in
    mapCache (Cache { iCache | user = Just uuid }) general


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


mode : General -> Mode
mode (General internals) =
    internals.config.mode



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
        |> required "network" Network.decoder
        |> required "fullscreen" Decode.bool


cacheDecoder : Decoder Cache
cacheDecoder =
    Decode.succeed ICache
        |> required "version" Data.Version.decoder
        |> required "theme" Theme.decoder
        |> optional "user" (Decode.nullable UUID.decoder) Nothing
        |> Decode.map Cache


defaultCacheDecoder : Version -> Decoder Cache
defaultCacheDecoder currentVersion =
    Decode.null (defaultCache currentVersion)


encodeCache : Cache -> Value
encodeCache (Cache c) =
    Encode.object
        [ ( "version", Data.Version.encode c.version )
        , ( "theme", Theme.encode c.theme )
        , ( "user"
          , case c.user of
                Just uuid ->
                    UUID.encode uuid

                Nothing ->
                    Encode.null
          )
        ]
