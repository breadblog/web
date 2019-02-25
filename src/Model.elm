module Model exposing (Cache, ErrorPage(..), Model, Post, Route(..), Slug(..), Theme(..))

import Browser.Navigation exposing (Key)
import Time
import Url


type Route
    = Fork
    | DarkHome
    | DarkPost Slug
    | QnHome
    | QnPost Slug
    | About
    | NotFound
    | Error ErrorPage


type ErrorPage
    = CorruptCache String


type alias Model =
    { cache : Cache
    , key : Key
    , route : Route
    , postCache : List Post
    }


type alias Post =
    { title : String
    , content : String
    , author : String
    , date : Time.Posix
    }


type alias Cache =
    { version : String
    , theme : Theme
    }


type Slug
    = Slug String


type Theme
    = Dark
    | Light
