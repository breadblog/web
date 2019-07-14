port module Data.General exposing (General, Msg(..), authors, flagsDecoder, fullscreen, fullscreenSub, init, key, mapUser, mode, networkSub, postPreviews, problems, pushProblem, tags, theme, update, updateAuthors, user, version)

import Api exposing (Url)
import Browser.Navigation exposing (Key)
import Data.Author as Author exposing (Author)
import Data.Config exposing (Config)
import Data.Markdown as Markdown
import Data.Mode as Mode exposing (Mode(..))
import Data.Network as Network exposing (Network(..))
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
    , problems : List (Problem Msg)
    , config : Config
    , network : Network
    , temp : Temp
    , fullscreen : Bool
    }


type Cache
    = Cache ICache


type alias ICache =
    { version : Version
    , theme : Theme
    , tags : List Tag
    , authors : List Author
    , postPreviews : List (Post Core Preview)
    , user : Maybe UUID
    }


type alias Temp =
    { postPreviews : List (Post Core Preview)
    , authors : List Author
    , tags : List Tag
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
            , temp = defaultTemp
            , fullscreen = decoded.fullscreen
            }
                |> General
    in
    ( general
    , Cmd.batch
        [ setCache decoded.cache
        , updateAuthors general
        , updatePosts general
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
    | ToggleTag Tag
    | ToggleAuthor Author
    | TogglePost (Post Core Preview)
    | UpdateNetwork Network
    | NetworkProblem Decode.Error
    | UpdateAuthors
    | GotAuthors (Result Http.Error (List Author))
    | UpdatePosts
    | GotPosts (Result Http.Error (List (Post Core Preview)))
    | UpdateTags
    | GotTags (Result Http.Error (List Tag))
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

                TogglePost post ->
                    let
                        posts_ =
                            togglePostList post iCache.postPreviews
                    in
                    updateCache general { iCache | postPreviews = posts_ }

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

                UpdateAuthors ->
                    ( general, updateAuthors general )

                GotAuthors res ->
                    updateResource
                        { compare = Author.compare
                        , transform = Author.mergeFromApi
                        , res = res
                        , general = general
                        , triggerUpdate = updateAuthorsAt
                        , setInTemp = \authors_ temp_ -> { temp_ | authors = authors_ }
                        , setInCache = \authors_ iCache_ -> { iCache_ | authors = authors_ }
                        , getFromTemp = .authors
                        , getFromCache = .authors
                        , name = "author"
                        }

                UpdatePosts ->
                    ( general, updatePosts general )

                GotPosts res ->
                    updateResource
                        { compare = Post.compare
                        , transform = Post.mergeFromApi
                        , res = res
                        , general = general
                        , triggerUpdate = updatePostsAt
                        , setInTemp = \postPreviews_ temp_ -> { temp_ | postPreviews = postPreviews_ }
                        , setInCache = \postPreviews_ iCache_ -> { iCache_ | postPreviews = postPreviews_ }
                        , getFromTemp = .postPreviews
                        , getFromCache = .postPreviews
                        , name = "post"
                        }

                UpdateTags ->
                    ( general, updateTags general )

                GotTags res ->
                    updateResource
                        { compare = Tag.compare
                        , transform = Tag.mergeFromApi
                        , res = res
                        , general = general
                        , triggerUpdate = updateTagsAt
                        , setInTemp = \tags_ temp_ -> { temp_ | tags = tags_ }
                        , setInCache = \tags_ iCache_ -> { iCache | tags = tags_ }
                        , getFromTemp = .tags
                        , getFromCache = .tags
                        , name = "tag"
                        }

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


updateResource : UpdateResourceInfo t -> ( General, Cmd Msg )
updateResource info =
    case info.res of
        Ok fromApi ->
            let
                (General internals) =
                    info.general

                temp =
                    internals.temp

                fromTemp =
                    info.getFromTemp temp
            in
            if List.isEmpty fromApi then
                -- If list is empty, then we have retrieved all of
                -- the values, and it's time to update the cache
                let
                    (Cache iCache) =
                        internals.cache

                    fromCache =
                        info.getFromCache iCache

                    updatedCacheList =
                        Util.joinLeftWith
                            info.transform
                            info.compare
                            -- fromTemp is aggregated resources from API (primary data)
                            fromTemp
                            -- fromCache is old resources from Cache (secondary data)
                            fromCache

                    updatedTempGeneral =
                        updateTemp info.general (info.setInTemp [] temp)
                in
                updateCache updatedTempGeneral (info.setInCache updatedCacheList iCache)

            else
                -- If list is not empty should append to temp list and
                -- retrieve more resources from API (pagination)
                let
                    updatedTempList =
                        fromTemp ++ fromApi

                    updatedGeneral =
                        updateTemp info.general (info.setInTemp updatedTempList temp)

                    offset =
                        updatedTempList
                            |> toOffset
                            |> (+) 1
                in
                ( updatedGeneral, info.triggerUpdate updatedGeneral offset )

        Err err ->
            let
                message =
                    "Failed to update list of " ++ info.name ++ "s"

                problem =
                    Problem.create message (HttpError err) Nothing

                updatedGeneral =
                    pushProblem problem info.general
            in
            ( updatedGeneral, Cmd.none )


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
updateAuthors general =
    updateAuthorsAt general 0


updateAuthorsAt : General -> Int -> Cmd Msg
updateAuthorsAt (General general) page =
    let
        start =
            page * 10

        path =
            String.join ""
                [ "/author/public/"
                , "?count="
                , String.fromInt Api.count
                , "&start="
                , String.fromInt start
                ]
    in
    Api.get
        { url = Api.url general.config.mode path
        , expect = Http.expectJson GotAuthors (Decode.list Author.decoder)
        }


updatePosts : General -> Cmd Msg
updatePosts general =
    updatePostsAt general 0


updatePostsAt : General -> Int -> Cmd Msg
updatePostsAt (General general) page =
    let
        start =
            page * 10

        path =
            String.join ""
                [ "/post/public/"
                , "?count="
                , String.fromInt Api.count
                , "&start="
                , String.fromInt start
                ]
    in
    Api.get
        { url = Api.url general.config.mode path
        , expect = Http.expectJson GotPosts (Decode.list <| Post.previewDecoder <| Just False)
        }


updateTags : General -> Cmd Msg
updateTags general =
    updateTagsAt general 0


updateTagsAt : General -> Int -> Cmd Msg
updateTagsAt (General general) page =
    let
        start =
            page * 10

        path =
            String.join ""
                [ "/tag/public/"
                , "?count="
                , String.fromInt Api.count
                , "&start="
                , String.fromInt start
                ]
    in
    Api.get
        { url = Api.url general.config.mode path
        , expect = Http.expectJson GotTags (Decode.list Tag.decoder)
        }


toOffset : List a -> Int
toOffset list =
    List.length list // Api.count


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


postPreviews : General -> List (Post Core Preview)
postPreviews general =
    general
        |> cache
        |> cacheInternals
        |> .postPreviews


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
        |> optional "tags"
            (Decode.list Tag.decoder)
            []
        |> optional "authors"
            (Decode.list Author.decoder)
            []
        |> optional "postPreviews"
            (Decode.list <| Post.previewDecoder <| Just False)
            []
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
