module Message exposing (Compound(..), Msg(..), map)

import Browser
import Data.General as General exposing (General)
import Data.Theme exposing (Theme)
import Html.Styled exposing (Html)
import Url exposing (Url)



{-
   These are global messages to be used across the
   entire application

   These messages are either handled in Main or their
   respective Data module
-}


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | GeneralMsg General.Msg
    | NoOp


type Compound e
    = Global Msg
    | Mod e


map : (a -> b) -> Compound a -> Compound b
map transform compound =
    case compound of
        Global msg ->
            Global msg

        Mod a ->
            Mod <| transform a
