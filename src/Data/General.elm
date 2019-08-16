port module Data.General exposing (General, Msg(..), flagsDecoder, focus, fullscreen, fullscreenSub, init, interval, key, mapUser, mode, network, networkSub, onResize, problems, pushProblem, pushVisit, screen, theme, update, updateRoute, user, version, visits)

import Api exposing (Url)
import Browser.Dom exposing (Viewport)
import Browser.Events
import Browser.Navigation exposing (Key)
import Data.Author as Author exposing (Author)
import Data.Config exposing (Config)
import Data.Markdown as Markdown
import Data.Mode as Mode exposing (Mode(..))
import Data.Network as Network exposing (Network(..))
import Data.Personalize as Personalize exposing (Visit)
import Data.Post as Post exposing (Core, Post, Preview)
import Data.Problem as Problem exposing (Description(..), Problem)
import Data.Route as Route exposing (Route(..))
import Data.Tag as Tag exposing (Tag)
import Data.Theme as Theme exposing (Theme(..))
import Data.UUID as UUID exposing (UUID)
import Data.Version exposing (Version)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode exposing (Value)
import List.Extra
import Task
import Time
import Util
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
    , route : Route
    , problems : List (Problem Msg)
    , config : Config
    , network : Network
    , temp : Temp
    , fullscreen : Bool
    , screen : Maybe Viewport
    }


type Cache
    = Cache ICache


type alias ICache =
    { version : Version
    , theme : Theme
    , user : Maybe UUID
    , visits : List Visit
    }


type alias Temp =
    { postPreviews : List (Post Core Preview)
    , authors : List Author
    , tags : List Tag
    }



{- Constructors -}


init : Route -> Key -> Value -> ( General, Cmd Msg )
init route key_ flags =
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
            , route = route
            , problems = cacheProblems
            , config = initConfig decoded
            , network = decoded.network
            , temp = defaultTemp
            , fullscreen = decoded.fullscreen
            , screen = Nothing
            }
                |> General
    in
    ( general
    , Cmd.batch
        [ setCache decoded.cache
        , updateViewport
        ]
    )


defaultCache : Version -> Cache
defaultCache currentVersion =
    { theme = Dark
    , version = currentVersion
    , user = Nothing
    , visits = []
    }
        |> Cache


defaultTemp =
    { postPreviews = []
    , authors = []
    , tags = []
    }


defaultFlags : Version -> Flags
defaultFlags version_ =
    { cache = defaultCache version_
    , mode = Production
    , network = Network.Offline
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
    | PushVisit Visit
    | Interval Time.Posix
    | OnViewport Viewport
    | OnResize Int Int



{- Update -}


update : Msg -> General -> ( General, Cmd Msg )
update msg general =
    let
        (Cache iCache) =
            cache general

        (General internals) =
            general

        temp =
            internals.temp

        ( newGeneral, cmd ) =
            case msg of
                Interval time ->
                    ( general, Cmd.none )

                SetTheme theme_ ->
                    updateCache general { iCache | theme = theme_ }

                UpdateNetwork updatedNetwork ->
                    let
                        previousNetwork =
                            internals.network

                        shouldRefresh =
                            previousNetwork == Network.Offline && updatedNetwork == Online
                    in
                    ( General { internals | network = updatedNetwork }
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
                    ( general, Api.logout (mode general) OnLogout )

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

                PushVisit visit ->
                    pushVisit visit general

                OnViewport updatedScreen ->
                    ( General { internals | screen = Just updatedScreen }
                    , Cmd.none
                    )

                OnResize _ _ ->
                    ( general
                    , Task.perform OnViewport Browser.Dom.getViewport
                    )
    in
    ( newGeneral
    , Cmd.batch
        [ cmd
        ]
    )


updateRoute : Route -> General -> General
updateRoute route (General internals) =
    General { internals | route = route }


pushVisit : Visit -> General -> ( General, Cmd Msg )
pushVisit visit general =
    let
        iCache =
            general
                |> cache
                |> cacheInternals

        maxCache =
            100

        updatedVisits =
            Personalize.pushVisit visit maxCache iCache.visits
    in
    updateCache general { iCache | visits = updatedVisits }


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


updateTemp : General -> Temp -> General
updateTemp general temp =
    let
        (General internals) =
            general
    in
    General { internals | temp = temp }


type alias UpdateResourceInfo t =
    -- Used to compare if two "t" values are equivalent
    { compare : t -> t -> Bool

    -- Used to merge two t values (left api, right cache)
    , transform : t -> t -> t

    -- response from API
    , res : Result Http.Error (List t)
    , general : General

    -- trigger new update for resource
    , triggerUpdate : General -> Int -> Cmd Msg

    -- set resource list in temp
    , setInTemp : List t -> Temp -> Temp

    -- set resource list in cache
    , setInCache : List t -> ICache -> ICache

    -- get resource list from temp
    , getFromTemp : Temp -> List t

    -- get resource list from cache
    , getFromCache : ICache -> List t

    -- name of resource
    , name : String
    }



-- updateResource : UpdateResourceInfo t -> ( General, Cmd Msg )
-- updateResource info =
--     let
--         (General internals) =
--             info.general
--     in
--     case info.res of
--         Ok fromApi ->
--             let
--                 temp =
--                     internals.temp
--                 fromTemp =
--                     info.getFromTemp temp
--             in
--             if List.isEmpty fromApi then
--                 -- If list is empty, then we have retrieved all of
--                 -- the values, and it's time to update the cache
--                 let
--                     (Cache iCache) =
--                         internals.cache
--                     fromCache =
--                         info.getFromCache iCache
--                     updatedCacheList =
--                         Util.joinLeftWith
--                             info.transform
--                             info.compare
--                             -- fromTemp is aggregated resources from API (primary data)
--                             fromTemp
--                             -- fromCache is old resources from Cache (secondary data)
--                             fromCache
--                     updatedTempGeneral =
--                         updateTemp info.general (info.setInTemp [] temp)
--                 in
--                 updateCache updatedTempGeneral (info.setInCache updatedCacheList iCache)
--             else
--                 -- If list is not empty should append to temp list and
--                 -- retrieve more resources from API (pagination)
--                 let
--                     updatedTempList =
--                         fromTemp ++ fromApi
--                     updatedGeneral =
--                         updateTemp info.general (info.setInTemp updatedTempList temp)
--                     offset =
--                         updatedTempList
--                             |> toOffset
--                             |> (+) 1
--                 in
--                 ( updatedGeneral, info.triggerUpdate updatedGeneral offset )
--         Err err ->
--             if internals.network == Online then
--                 let
--                     message =
--                         "Failed to update list of " ++ info.name ++ "s"
--                     problem =
--                         Problem.create message (HttpError err) Nothing
--                     updatedGeneral =
--                         pushProblem problem info.general
--                 in
--                 ( updatedGeneral, Cmd.none )
--             else if dataReady info.general then
--                 -- if we have data already, fail silently
--                 ( info.general, Cmd.none )
--             else
--                 -- if we don't have data, and something is offline, push to offline page
--                 ( info.general, Browser.Navigation.pushUrl (key info.general) (Route.toPath Route.Offline) )


togglePostList : Post Core Preview -> List (Post Core Preview) -> List (Post Core Preview)
togglePostList post list =
    List.Extra.updateIf
        (Post.compare post)
        (Post.mapFavorite
            (\m ->
                case m of
                    Just b ->
                        Just <| not b

                    Nothing ->
                        Nothing
            )
        )
        list



{- HTTP -}
-- updateAuthors : General -> Cmd Msg
-- updateAuthors general =
--     updateAuthorsAt general 0
-- updateAuthorsAt : General -> Int -> Cmd Msg
-- updateAuthorsAt (General general) page =
--     let
--         start =
--             page * 10
--         path =
--             String.join ""
--                 [ "/author/public/"
--                 , "?count="
--                 , String.fromInt Api.count
--                 , "&start="
--                 , String.fromInt start
--                 ]
--     in
--     Api.get
--         { url = Api.url general.config.mode path
--         , expect = Http.expectJson GotAuthors (Decode.list Author.decoder)
--         }
-- updatePosts : General -> Cmd Msg
-- updatePosts general =
--     updatePostsAt general 0
-- updatePostsAt : General -> Int -> Cmd Msg
-- updatePostsAt (General general) page =
--     let
--         start =
--             page * 10
--         path =
--             String.join ""
--                 [ "/post/public/"
--                 , "?count="
--                 , String.fromInt Api.count
--                 , "&start="
--                 , String.fromInt start
--                 ]
--     in
--     Api.get
--         { url = Api.url general.config.mode path
--         , expect = Http.expectJson GotPosts (Decode.list <| Post.previewDecoder <| Just False)
--         }
-- updateTags : General -> Cmd Msg
-- updateTags general =
--     updateTagsAt general 0
-- updateTagsAt : General -> Int -> Cmd Msg
-- updateTagsAt (General general) page =
--     let
--         start =
--             page * 10
--         path =
--             String.join ""
--                 [ "/tag/public/"
--                 , "?count="
--                 , String.fromInt Api.count
--                 , "&start="
--                 , String.fromInt start
--                 ]
--     in
--     Api.get
--         { url = Api.url general.config.mode path
--         , expect = Http.expectJson GotTags (Decode.list Tag.decoder)
--         }
{- Subs -}


interval : Sub Msg
interval =
    Time.every (1000 * 60) Interval


onResize : Sub Msg
onResize =
    Browser.Events.onResize OnResize



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
                Ok updatedNetwork ->
                    UpdateNetwork updatedNetwork

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


visits : General -> List Visit
visits general =
    general
        |> cache
        |> cacheInternals
        |> .visits


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



-- tags : General -> List Tag
-- tags general =
--     general
--         |> cache
--         |> cacheInternals
--         |> .tags
-- authors : General -> List Author
-- authors general =
--     general
--         |> cache
--         |> cacheInternals
--         |> .authors
-- postPreviews : General -> List (Post Core Preview)
-- postPreviews general =
--     general
--         |> cache
--         |> cacheInternals
--         |> .postPreviews


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


network : General -> Network
network (General internals) =
    internals.network


screen : General -> Maybe Viewport
screen (General internals) =
    internals.screen



{- Accessors (private) -}


cacheInternals : Cache -> ICache
cacheInternals (Cache iCache) =
    iCache



{- Helpers -}


{-| Checks if the data in general is ready to use
-}
updateViewport : Cmd Msg
updateViewport =
    Task.perform OnViewport Browser.Dom.getViewport



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
        |> required "user" (Decode.nullable UUID.decoder)
        |> required "visits" (Decode.list Personalize.visitDecoder)
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
        , ( "visits", Encode.list Personalize.encodeVisit c.visits )
        ]
