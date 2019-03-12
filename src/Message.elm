module Message exposing (Msg(..))

import Browser
import Url exposing (Url)
import Data.Theme exposing (Theme)
import Data.Cache as Cache


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | CacheMsg Cache.Msg
