port module Data.General exposing (General, Msg(..), authors, back, dismissProblem, fullscreen, login, logout, mapRoute, mapTheme, mapUser, mode, network, postPreviews, problems, pushProblem, pushUrl, replaceUrl, route, tags, theme, update, user)

import Api exposing (Url)
import Browser.Navigation as Nav exposing (Key)
import Data.Author as Author exposing (Author)
import Data.Config exposing (Config)
import Data.Login as Login
import Data.Markdown as Markdown
import Data.Mode as Mode exposing (Mode(..))
import Data.Network as Network exposing (Network(..))
import Data.Password exposing (Password)
import Data.Post as Post exposing (Core, Post, Preview)
import Data.Problem as Problem exposing (Description(..), Problem)
import Data.Route as Route exposing (Route(..))
import Data.Tag as Tag exposing (Tag)
import Data.Theme as Theme exposing (Theme(..))
import Data.UUID as UUID exposing (UUID)
import Data.Username exposing (Username)
import Data.Version exposing (Version)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode exposing (Value)
import List.Extra
import Util
import Version



{- Model -}


type General
    = General Internals


type alias Flags =
    { mode : Mode
    , cache : Cache
    , network : Network
    , fullscreen : Bool
    }


type alias Internals =
    { cache : Cache
    , key : Key
    , problems : List (Problem Msg)
    , config : Config
    , network : Network
    , temp : Temp
    , fullscreen : Bool
    , route : Route
    }


type alias Cache =
    { version : Version
    , theme : Theme
    , user : Maybe UUID
    , postPreviews : List (Post Core Preview)
    , tags : List Tag
    , authors : List Author
    }


type alias Temp =
    { postPreviews : List (Post Core Preview)
    , authors : List Author
    , tags : List Tag
    }



{- Constructors -}


init : Key -> Route -> Value -> ( General, Cmd Msg )
init applicationKey initialRoute flags =
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
            , key = applicationKey
            , route = initialRoute
            , problems = cacheProblems
            , config = initConfig decoded
            , network = decoded.network
            , temp = defaultTemp
            , fullscreen = decoded.fullscreen
            }
                |> General
    in
    ( general
    , Cmd.batch
        [ setCache decoded.cache
        , updateAuthors general
        , updatePostPreviews general
        , updateTags general
        ]
    )


defaultCache : Version -> Cache
defaultCache currentVersion =
    { theme = Dark
    , version = currentVersion
    , tags = []
    , authors = []
    , postPreviews = []
    , user = Nothing
    }


defaultTemp =
    { postPreviews = []
    , authors = []
    , tags = []
    }


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
    = InternalMsg IMsg
    | UpdateAuthors
    | UpdatePostPreviews
    | UpdateTags
    | Login Username Password
    | Logout
    | SetTheme Theme
    | NavigateTo Route
    | ReportErr (Problem Msg)
    | DismissProblem Int
    | WithDismiss Int Msg
    | FullscreenElement String
    | ExitFullscreen
    | PushProblem (Problem Msg)
    | GoBack


type IMsg
    = GotAuthors (Result Http.Error (List Author))
    | GotPostPreviews (Result Http.Error (List (Post Core Preview)))
    | GotTags (Result Http.Error (List Tag))
    | GotLogin (Result Http.Error Login.Response)
    | GotLogout (Result Http.Error ())
    | SetFullscreen Bool
    | SetNetwork Network



{- Update (public) -}


update : Msg -> General -> ( General, Cmd Msg )
update msg general =
    case msg of
        InternalMsg iMsg ->
            internalsUpdate iMsg general

        UpdateAuthors ->
            ( general, updateAuthors general )

        UpdatePostPreviews ->
            ( general, updatePostPreviews general )

        UpdateTags ->
            ( general, updateTags general )

        Login username password ->
            ( general
            , login username password general
            )

        Logout ->
            ( general, logout general )

        SetTheme fresh ->
            mapTheme (always fresh) general

        NavigateTo targetRoute ->
            ( general
            , pushUrl general <| Route.toPath targetRoute
            )

        -- TODO: implement
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

        PushProblem problem ->
            ( pushProblem problem general
            , Cmd.none
            )

        GoBack ->
            ( general
            , back general 1
            )



{- Update (private) -}


internalsUpdate : IMsg -> General -> ( General, Cmd Msg )
internalsUpdate msg general =
    let
        -- TODO: replace me
        replaceMe =
            ( General internals, Cmd.none )

        (General internals) =
            general
    in
    case msg of
        GotAuthors res ->
            case res of
                Ok freshAuthors ->
                    replaceMe

                Err err ->
                    replaceMe

        GotPostPreviews res ->
            case res of
                Ok freshPosts ->
                    replaceMe

                Err posts ->
                    replaceMe

        GotTags res ->
            case res of
                Ok freshTags ->
                    replaceMe

                Err err ->
                    replaceMe

        GotLogin res ->
            case res of
                Ok { uuid } ->
                    replaceMe

                Err err ->
                    replaceMe

        GotLogout res ->
            case res of
                Ok _ ->
                    replaceMe

                Err err ->
                    replaceMe

        SetFullscreen value ->
            ( General { internals | fullscreen = value }
            , Cmd.none
            )

        SetNetwork value ->
            ( General { internals | network = value }
            , Cmd.none
            )



{- Accessors (public) -}


pushProblem : Problem Msg -> General -> General
pushProblem problem (General general) =
    { general | problems = problem :: general.problems }
        |> General


{-| Although "Key" is not used, it enforces that only Main can call this transform
-}
mapRoute : Key -> (Route -> Route) -> General -> General
mapRoute _ transform (General internals) =
    General { internals | route = transform internals.route }


mapTheme : (Theme -> Theme) -> General -> ( General, Cmd Msg )
mapTheme transform =
    mapCache (\c -> { c | theme = transform c.theme })


dismissProblem : Int -> General -> General
dismissProblem index =
    mapProblems (List.Extra.removeAt index)


problems : General -> List (Problem Msg)
problems =
    toInternals >> .problems


mode : General -> Mode
mode =
    toInternals >> .config >> .mode


network : General -> Network
network =
    toInternals >> .network


fullscreen : General -> Bool
fullscreen =
    toInternals >> .fullscreen


route : General -> Route
route =
    toInternals >> .route


theme : General -> Theme
theme =
    toCache >> .theme


user : General -> Maybe UUID
user =
    toCache >> .user


postPreviews : General -> List (Post Core Preview)
postPreviews =
    toCache >> .postPreviews


tags : General -> List Tag
tags =
    toCache >> .tags


authors : General -> List Author
authors =
    toCache >> .authors



{- Accessors (private) -}


toInternals : General -> Internals
toInternals (General internals) =
    internals


toCache : General -> Cache
toCache =
    toInternals >> .cache



-- TODO: check at application start


mapUser : (Maybe UUID -> Maybe UUID) -> General -> ( General, Cmd Msg )
mapUser transform =
    mapCache (\c -> { c | user = transform c.user })


mapCache : (Cache -> Cache) -> General -> ( General, Cmd Msg )
mapCache transform (General internals) =
    let
        updatedCache =
            transform internals.cache
    in
    ( General { internals | cache = updatedCache }
    , setCache updatedCache
    )


{-| Sets the cache via ports
-}
setCache : Cache -> Cmd msg
setCache c =
    c
        |> encodeCache
        |> setCachePort


mapProblems : (List (Problem Msg) -> List (Problem Msg)) -> General -> General
mapProblems transform (General internals) =
    General { internals | problems = transform internals.problems }



{- Http -}


updateAuthors : General -> Cmd Msg
updateAuthors general =
    Api.getAuthors
        { msg = GotAuthors >> InternalMsg
        , user = user general
        , mode = mode general
        , offset = 0
        }


updateTags : General -> Cmd Msg
updateTags general =
    Api.getTags
        { msg = GotTags >> InternalMsg
        , user = user general
        , mode = mode general
        , offset = 0
        }


updatePostPreviews : General -> Cmd Msg
updatePostPreviews general =
    Api.getPostPreviews
        { msg = GotPostPreviews >> InternalMsg
        , user = user general
        , mode = mode general
        , offset = 0
        }


login : Username -> Password -> General -> Cmd Msg
login username password general =
    Api.login
        { username = username
        , password = password
        , msg = GotLogin >> InternalMsg
        , mode = mode general
        }


logout : General -> Cmd Msg
logout general =
    Api.logout
        { msg = GotLogout >> InternalMsg
        , mode = mode general
        }



{- Navigation -}


pushUrl : General -> String -> Cmd msg
pushUrl =
    toInternals >> .key >> Nav.pushUrl


replaceUrl : General -> String -> Cmd msg
replaceUrl =
    toInternals >> .key >> Nav.replaceUrl


back : General -> Int -> Cmd msg
back =
    toInternals >> .key >> Nav.back



{- Ports -}


port focus : String -> Cmd msg


port exitFullscreen : () -> Cmd msg


port fullscreenElement : String -> Cmd msg


port setCachePort : Value -> Cmd msg


port getNetworkPort : (Value -> msg) -> Sub msg


port getFullscreenPort : (Value -> msg) -> Sub msg



{- Subscriptions -}


networkSub : Sub Msg
networkSub =
    getNetworkPort
        (\v ->
            case Decode.decodeValue Network.decoder v of
                Ok nw ->
                    InternalMsg <| SetNetwork nw

                Err err ->
                    PushProblem <|
                        Problem.create
                            "Failed to fetch network status"
                            (JsonError err)
                            Nothing
        )


fullscreenSub : Sub Msg
fullscreenSub =
    getFullscreenPort
        (\v ->
            case Decode.decodeValue Decode.bool v of
                Ok fs ->
                    InternalMsg <| SetFullscreen fs

                Err err ->
                    PushProblem <|
                        Problem.create
                            "Failed to determine fullscreen state"
                            (JsonError err)
                            Nothing
        )



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
    Decode.succeed Cache
        |> required "version" Data.Version.decoder
        |> required "theme" Theme.decoder
        |> optional "user" (Decode.nullable UUID.decoder) Nothing
        |> optional "postPreviews"
            (Decode.list Post.previewDecoder)
            []
        |> optional "tags"
            (Decode.list Tag.decoder)
            []
        |> optional "authors"
            (Decode.list Author.decoder)
            []


defaultCacheDecoder : Version -> Decoder Cache
defaultCacheDecoder currentVersion =
    Decode.null (defaultCache currentVersion)


encodeCache : Cache -> Value
encodeCache c =
    Encode.object
        [ ( "version", Data.Version.encode c.version )
        , ( "theme", Theme.encode c.theme )
        , ( "tags", Encode.list Tag.encode c.tags )
        , ( "authors", Encode.list Author.encode c.authors )
        , ( "postPreviews", Encode.list Post.encodePreview c.postPreviews )
        , ( "user"
          , case c.user of
                Just uuid ->
                    UUID.encode uuid

                Nothing ->
                    Encode.null
          )
        ]
