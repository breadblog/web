port module Data.Context exposing (Context, Msg(..), flagsDecoder, focus, getFullscreen, fullscreenSub, init, getKey, mapUser, getMode, networkSub, getProblems, pushProblem, getTheme, update, getUser, getVersion, isPostLiked)

import Api
import Browser.Navigation exposing (Key)
import Data.Tag as Tag exposing (Tag)
import Data.Post as Post exposing (Post, Core)
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


type Context
    = Context IContext


type alias Flags =
    { mode : Mode
    , cache : Cache
    , network : Network
    , fullscreen : Bool
    }


type alias IContext =
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
    , likedPosts : List UUID
    , ignoredTags : List UUID
    }


{- Constructors -}


init : Key -> Value -> ( Context, Cmd Msg )
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

        context =
            { cache = decoded.cache
            , key = key_
            , problems = cacheProblems
            , config = initConfig decoded
            , network = decoded.network
            , fullscreen = decoded.fullscreen
            }
                |> Context
    in
    ( context
    , Cmd.batch
        [ setCache decoded.cache
        ]
    )


defaultCache : Version -> Cache
defaultCache currentVersion =
    { theme = Dark
    , version = currentVersion
    , user = Nothing
    , likedPosts = []
    , ignoredTags = []
    }
        |> Cache


defaultFlags : Version -> Flags
defaultFlags version_ =
    { cache = defaultCache version_
    , mode = Production
    , network = Online
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
    | TogglePost UUID
    | GoBack



{- Update -}


update : Msg -> Context -> ( Context, Cmd Msg )
update msg context =
    let
        (Cache iCache) =
            getCache context

        (Context internals) =
            context

        ( newGeneral, cmd ) =
            case msg of
                SetTheme newTheme ->
                    updateCache context { iCache | theme = newTheme }

                UpdateNetwork network ->
                    ( Context { internals | network = network }
                    , Cmd.none
                    )

                NetworkProblem err ->
                    let
                        problem =
                            Problem.create "Network problem" (JsonError err) Nothing
                    in
                    ( Context { internals | problems = problem :: internals.problems }
                    , Cmd.none
                    )

                TryLogout ->
                    ( context, tryLogout context )

                OnLogout res ->
                    case res of
                        Ok _ ->
                            updateCache context { iCache | user = Nothing }

                        Err err ->
                            let
                                problem =
                                    Problem.create
                                        "Failed to logout"
                                        (HttpError err)
                                        Nothing
                            in
                            ( pushProblem problem context
                            , Cmd.none
                            )

                NavigateTo route ->
                    navigateTo route context

                ReportErr _ ->
                    ( context, Cmd.none )

                DismissProblem index ->
                    ( dismissProblem index context, Cmd.none )

                WithDismiss index nestedMsg ->
                    update nestedMsg <| dismissProblem index context

                FullscreenElement class ->
                    ( context, fullscreenElement class )

                ExitFullscreen ->
                    ( context, exitFullscreen () )

                UpdateFullscreen fs ->
                    ( Context { internals | fullscreen = fs }
                    , Cmd.none
                    )

                PushProblem problem ->
                    ( pushProblem problem context
                    , Cmd.none
                    )

                TogglePost uuid ->
                    updateCache context
                        { iCache | likedPosts = togglePost uuid iCache.likedPosts
                        }

                GoBack ->
                    ( context
                    , Browser.Navigation.back (getKey context) 1
                    )
    in
    ( newGeneral
    , Cmd.batch
        [ cmd
        ]
    )


updateCache : Context -> ICache -> ( Context, Cmd Msg )
updateCache (Context iContext) updatedCacheInternals =
    let
        updatedCache =
            Cache updatedCacheInternals
        
    in
    ( Context { iContext | cache = updatedCache }
    , setCache updatedCache
    )


togglePost : UUID -> List UUID -> List UUID
togglePost uuid list =
    case List.Extra.find (UUID.compare uuid) list of
        Just _ ->
            List.filter (UUID.compare uuid >> not) list
        
        Nothing ->
            uuid :: list


dismissProblem : Int -> Context -> Context
dismissProblem index (Context internals) =
    Context { internals | problems = List.Extra.removeAt index internals.problems }


navigateTo : Route -> Context -> ( Context, Cmd msg )
navigateTo route context =
    ( context
    , Browser.Navigation.pushUrl (getKey context) (Route.toPath route)
    )


mapCache : Cache -> Context -> ( Context, Cmd msg )
mapCache cache_ (Context general_) =
    ( Context { general_ | cache = cache_ }
    , setCache cache_
    )


{- HTTP -}

tryLogout : Context -> Cmd Msg
tryLogout context =
    let
        url =
            Api.url (getMode context) "/logout/"

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


getFullscreen : Context -> Bool
getFullscreen (Context internals) =
    internals.fullscreen


getCache : Context -> Cache
getCache (Context internals) =
    internals.cache


getVersion : Context -> Version
getVersion context =
    context
        |> getCache
        |> toCacheInternals
        |> .version


getTheme: Context -> Theme
getTheme context =
    context
        |> getCache
        |> toCacheInternals
        |> .theme


getUser : Context -> Maybe UUID
getUser context =
    context
        |> getCache
        |> toCacheInternals
        |> .user


mapUser : UUID -> Context -> ( Context, Cmd msg )
mapUser uuid context =
    let
        (Context internals) =
            context

        (Cache iCache) =
            internals.cache
    in
    mapCache (Cache { iCache | user = Just uuid }) context


getProblems : Context -> List (Problem Msg)
getProblems (Context context) =
    context.problems


pushProblem : Problem Msg -> Context -> Context
pushProblem problem (Context context) =
    { context | problems = problem :: context.problems }
        |> Context


getKey : Context -> Key
getKey (Context internals) =
    internals.key


getMode : Context -> Mode
getMode (Context internals) =
    internals.config.mode


isPostLiked : Context -> Post Core c -> Bool
isPostLiked context post =
    let
        predicate =
            post
            |> Post.getUUID
            |> UUID.compare

        (Cache iCache) =
            getCache context

    in
    List.any predicate iCache.likedPosts
    


{- Accessors (private) -}


toCacheInternals : Cache -> ICache
toCacheInternals (Cache iCache) =
    iCache


toLikedPosts : Cache -> List UUID
toLikedPosts cache =
    cache
    |> toCacheInternals
    |> .likedPosts



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
        |> optional "likedPosts" (Decode.list UUID.decoder) []
        |> optional "ignoredTags" (Decode.list UUID.decoder) []
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
