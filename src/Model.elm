module Model exposing (Cache, ErrorPage(..), Model, Post, Route(..), Slug(..), Theme(..))


import Browser.Navigation exposing (Key)
import Url
import Data.Version as Version
import Data.Post as Post exposing (Post)


type alias Model =
    { key : Key
    , route : Route
    , content : Content
    }

{-
    How do we make impossible states impossible here?

    If there is an error, there may still be other data? But it might be corrupt, so probably best
    if it is impossible to access? But then we also can't recover from it

    There will always be a key and route

    There will always be a postCache, it just might be empty
    There might not be a cache, as it might be corrupt

    How do we match these individual error paths with the routes?

    Seems impossible with the way that routes are currently setup
-}

type Content
    = Error Error
    | Working WorkingModel


type Error
    = CorruptCache String
    | InvalidVersion Version.Error


type alias WorkingModel =
    { cache : Cache
    , key : Key
    , route : Route
    , postCache : List Post
    }


type Route
    = Fork
    | DarkHome
    | DarkPost Slug
    | QnHome
    | QnPost Slug
    | About
    | NotFound
    | Error Error


type alias Cache =
    { version : String
    , theme : Theme
    }


type Slug
    = Slug String


type Theme
    = Dark
    | Light
