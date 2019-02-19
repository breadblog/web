port module Port exposing (setCache)

import Json.Encode as E
import Message exposing (Msg)
import Model exposing (Cache)


port cacheSet : E.Value -> Cmd msg


setCache : Cache -> Cmd msg
setCache cache =
    cache
        |> encodeCache
        |> cacheSet


encodeCache : Cache -> E.Value
encodeCache cache =
    E.object
        [ ( "version", E.string cache.version )
        ]
