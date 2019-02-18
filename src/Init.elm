module Init exposing (init)


import Browser.Navigation as Nav
import Url
import Json.Decode as Decode exposing (Value, field, string)
import Json.Decode.Pipeline exposing (required, optional)
import Model exposing (Model, Cache)
import Message exposing (Msg)


init : Value -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( defaultModel (initCache flags) url key
    , Cmd.none
    )


defaultModel : Cache -> Url.Url -> Nav.Key -> Model
defaultModel cache url key =
    { url = url
    , key = key
    , cache = cache
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
        ( Decode.succeed Cache
            |> optional "version" string defaultCache.version
        )


defaultCache : Cache
defaultCache =
    { version = "0.0.1"
    }
