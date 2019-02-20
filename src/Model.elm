module Model exposing (Cache, Model)

import Browser.Navigation exposing (Key)
import Url
import Time
import Nav exposing (Route)


type alias Model =
    { cache : Cache
    , key : Key
    , route: Route
    }


type alias Post =
    { title : String
    , content : String
    , author : String
    , date: Time.Posix
    }


type alias Cache =
    { version : String
    }
