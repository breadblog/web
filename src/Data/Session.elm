module Data.Session exposing (Session, init)

import Browser.Navigation exposing (Key)
import Data.Author as Author exposing (Author)
import Data.Problem exposing (Problem)
import Message exposing (Compound)



{-
   Session

   Contains state global to the application that is stored in memory
--
--
-}
{--Model --}

type Never
    = Never Never



type alias Session =
    { user : Maybe Author
    , key : Key
    , problem : Maybe (Problem (Compound Never))
    }


init : Key -> Session
init key =
    { user = Nothing
    , key = key
    }
