module Message exposing (Msg(..))

import Browser
import Data.Cache as Cache
import Data.Theme exposing (Theme)
import Url exposing (Url)


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | CacheMsg Cache.Msg
    | NoOp
