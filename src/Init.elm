module Init exposing (init)

import Browser.Navigation exposing (Key)
import Json.Decode as Decode exposing (Value, field, string)
import Json.Decode.Pipeline exposing (optional, required)
import Message exposing (Msg)
import Model exposing (Cache, Model, Route)
import Nav exposing (urlToRoute)
import Port exposing (setCache)
import Url


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
    case Decode.decodeValue decodeCache value of
        Ok cache ->
            cache

        Err _ ->
            defaultCache


decodeCache : Decode.Decoder Cache
decodeCache =
    field "cache"
        (Decode.succeed Cache
            |> optional "version" string defaultCache.version
        )


defaultCache : Cache
defaultCache =
    { version = "0.0.1"
    }



-- Migrations
