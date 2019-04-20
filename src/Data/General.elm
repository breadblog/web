{-
   General data accessible to all Page modules
-}


module Data.General exposing (General, cache, init, session)

import Data.Cache exposing (Cache)
import Data.Session exposing (Session)
import Data.Theme exposing (Theme)


type General
    = General Internals


type alias Internals =
    { cache : Cache
    , session : Session
    }



-- Constructors --


init : Session -> Cache -> Theme -> General
init s c t =
    General
        { cache = c
        , session = s
        }



-- Accessors --


cache : General -> Cache
cache (General internals) =
    internals.cache


session : General -> Session
session (General internals) =
    internals.session
