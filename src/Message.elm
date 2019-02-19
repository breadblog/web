module Message exposing (Msg(..))

import Browser
import Model exposing (Cache)
import Url


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NoOp
