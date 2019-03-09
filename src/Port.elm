port module Port exposing (setCache)

import Json.Encode as E
import Message exposing (Msg)
import Data.Cache as Cache exposing (Cache)
import Data.Theme as Theme exposing (Theme(..))
import Data.Version as Version exposing (Version)


port cacheSet : E.Value -> Cmd msg


setCache : Cache -> Cmd msg
setCache cache =
    cache
        |> encodeCache
        |> cacheSet


encodeCache : Cache -> E.Value
encodeCache cache =
    E.object
        [ ( "version", E.string <| (
            cache
                |> Cache.version
                |> Version.toString
            
        ) )
        , ( "theme", E.string <| (
            cache
                |> Cache.theme
                |> Theme.toString
        ) )
        ]
