{-
    General data accessible to all Page modules
-}
module Data.General exposing (General, cache, session, init)


import Data.Session exposing (Session)
import Data.Cache exposing (Cache)


type General =
    General Internals


type alias Internals =
    { cache : Cache
    , session : Session
    }


-- Constructors --


init : Session -> Cache -> General
init s c =
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
