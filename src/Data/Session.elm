module Data.Session exposing (Session)


import Browser.Navigation exposing (Key)
import Data.User as User exposing (User)

{-
    Session

    Contains state global to the application that is stored in memory
-}

type alias Session =
    { user : Maybe User
    , key : Key
    }
