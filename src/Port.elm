port module Port exposing (setCache)

import Json.Encode as E
import Message exposing (Msg)
import Model exposing (Cache, Theme(..))


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
        , ( "theme", E.string (themeToString cache.theme))
        ]


themeToString : Theme -> String
themeToString theme =
    case theme of
        Light -> "light"

        Dark -> "dark"
