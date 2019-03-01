module Init exposing (init)

import Browser.Navigation exposing (Key)
import Json.Decode as Decode exposing (Value, field, string)
import Json.Decode.Pipeline exposing (optional, required)
import Message exposing (Msg)
import Model exposing (Cache, Model, Route, Theme(..))
import Nav exposing (urlToRoute)
import Port exposing (setCache)
import Url
import Version


init : Value -> Url.Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        cache =
            initCache flags
    in
    ( defaultModel cache url key
    , setCache cache
    )


defaultModel : Cache -> Url.Url -> Key -> Model
defaultModel cache url key =
    { route = urlToRoute url
    , key = key
    , cache = cache
    , postCache = []
    }


initCache : Value -> Cache
initCache value =
    case Decode.decodeValue cacheDecoder value of
        Ok cache ->
            cache

        Err _ ->
            defaultCache


cacheDecoder : Decode.Decoder Cache
cacheDecoder =
    field "cache"
        (Decode.succeed Cache
            |> optional "version" string defaultCache.version
            |> optional "theme" themeDecoder defaultCache.theme
        )


themeDecoder : Decode.Decoder Theme
themeDecoder =
    string
        |> Decode.andThen
            (\str ->
                case str of
                    "light" ->
                        Decode.succeed Light

                    "dark" ->
                        Decode.succeed Dark

                    somethingElse ->
                        Decode.fail <| "Unknown theme" ++ somethingElse
            )


defaultCache : Cache
defaultCache =
    { version = Version.current
    , theme = Light
    }



-- Migrations
