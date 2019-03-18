module Message exposing (Msg(..))

import Browser
import Data.Cache as Cache
import Data.Theme exposing (Theme)
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
    | CacheMsg Cache.Msg
    | NoOp
