port module Data.General exposing (General, Msg(..), authors, flagsDecoder, host, init, key, networkSub, problems, pushProblem, tags, theme, update, updateAuthors, version)

import Api exposing (Url)
import Browser.Navigation exposing (Key)
import Data.Author as Author exposing (Author)
import Data.Config exposing (Config)
import Data.Markdown as Markdown
import Data.Mode as Mode exposing (Mode(..))
import Data.Network as Network exposing (Network(..))
import Data.Post as Post exposing (Post, Preview)
import Data.Problem as Problem exposing (Description(..), Problem)
import Data.Tag as Tag exposing (Tag)
import Data.Theme as Theme exposing (Theme(..))
import Data.Version exposing (Version)
import Util
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode exposing (Value)
import Version



{- Model -}


type General
    = General IGeneral


type alias Flags =
    { mode : Mode
    , cache : Cache
    , network : Network
    }


type alias IGeneral =
    { cache : Cache
    , user : Maybe Author
    , key : Key
    , problems : List (Problem Msg)
    , config : Config
    , network : Network
    , temp : Temp
    }


type Cache
    = Cache ICache


type alias ICache =
    { version : Version
    , theme : Theme
    , tags : List Tag
    , authors : List Author
    , postPreviews : List (Post Preview)
    }


type alias Temp =
    { postPreviews : List (Post Preview)
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
            , network = decoded.network
            , temp = defaultTemp
            }
                |> General
    in
    ( general
    , Cmd.batch
        [ setCache decoded.cache
        , updateAuthors general
        ]
    )


defaultCache : Version -> Cache
defaultCache currentVersion =
    { theme = Dark
    , version = currentVersion
    , tags = []
    , authors = []
    , postPreviews = []
    }
        |> Cache


defaultTemp =
    { postPreviews = []
    , authors = []
    }


defaultFlags : Version -> Flags
defaultFlags version_ =
    { cache = defaultCache version_
    , mode = Production
    , network = Offline
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
    | UpdateAuthors
    | GotAuthors (Result Http.Error (List Author))
    | UpdateNetwork Network
    | NetworkProblem Decode.Error



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

                UpdateAuthors ->
                    ( general, updateAuthors general )

                GotAuthors res ->
                    case updateFromApi "authors" Author.compare Author.mergeFromApi res temp.authors of
                        Ok (maybeUpdatedList, updatedTemp) ->
                            case maybeUpdatedList of
                                Just updatedList ->
                                    updateCache (updateTemp general { temp | authors = updatedTemp }) { iCache | authors = updatedList }

                                Nothing ->
                                    ( updateTemp general { temp | authors = updatedTemp }, Cmd.none )

                        Err problem ->
                            ( { internals | problems = problem :: internals.problems }
                                |> General
                            , Cmd.none
                            )

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


updateTemp : General -> Temp -> General
updateTemp general temp =
    let
        (General internals) =
            general
    in
    General { internals | temp = temp }


updateFromApi : String -> (t -> t -> Bool) -> (t -> t -> t) -> Result Http.Error (List t) -> List t -> Result (Problem Msg) (Maybe (List t), List t)
updateFromApi name compare transform res fromTemp =
    case res of
        Ok fromApi ->
            if List.isEmpty fromApi then
                let
                    updatedList =
                        Just <|
                            Util.joinLeftWith
                                transform
                                compare
                                fromApi
                                fromTemp

                    updatedTemp =
                        []

                in
                Ok ( updatedList, updatedTemp )

            else
                let
                    updatedTemp =
                        fromTemp ++ fromApi

                    updatedList =
                        Nothing

                in
                Ok ( updatedList, updatedTemp )

        Err err ->
            Err <|
                Problem.create
                    ("Failed to update " ++ name)
                    (HttpError err)
                    Nothing


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
                , String.fromInt count
                , "&start="
                , String.fromInt start
                ]
    in
    Api.get
        { url = Api.url general.config.mode path
        , expect = Http.expectJson GotAuthors (Decode.list Author.decoder)
        }


count : Int
count =
    10


toOffset : List a -> Int
toOffset list =
    List.length list // count



{- Ports -}


port setCachePort : Value -> Cmd msg


setCache : Cache -> Cmd msg
setCache c =
    c
        |> encodeCache
        |> setCachePort


port getNetworkPort : (Value -> msg) -> Sub msg


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


host : General -> Mode
host (General internals) =
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
            (Decode.list Post.previewDecoder)
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
