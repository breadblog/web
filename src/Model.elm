module Model exposing (Cache, Model)

import Browser.Navigation as Nav
import Url


type alias Model =
    { cache : Cache
    , key : Nav.Key
    , url : Url.Url
    }


type alias Cache =
    { version : String
    }
