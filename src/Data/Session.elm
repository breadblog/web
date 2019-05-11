module Data.Session exposing (Session, init)

import Browser.Navigation exposing (Key)
import Data.Author as Author exposing (Author)



{-
   Session

   Contains state global to the application that is stored in memory
-}
{--Model --}


type alias Session =
    { user : Maybe Author
    , key : Key
    }


init : Key -> Session
init key =
    { user = Nothing
    , key = key
    }
