module Model exposing (Cache, Model)

import Browser.Navigation exposing (Key)
import Nav exposing (Route)
import Time
import Url


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
