module Model exposing (..)

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


type alias Model =
    { cache : Cache
    , key : Key
    , route : Route
    }


type alias Post =
    { title : String
    , content : String
    , author : String
    , date : Time.Posix
    }


type alias Cache =
    { version : String
    }


type Slug
    = Slug String
