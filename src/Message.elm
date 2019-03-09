module Message exposing (Msg(..))

import Browser
import Url exposing (Url)


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | ToggleTheme
    | NoOp
