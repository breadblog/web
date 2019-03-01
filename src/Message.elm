module Message exposing (Msg(..))

import Browser
import Model exposing (Cache, Route)
import Url


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | ToggleTheme
    | NoOp
