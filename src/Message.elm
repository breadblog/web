module Message exposing (Msg(..))


import Browser
import Url
import Model exposing (Cache)


type Msg
  = LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url
  | SetCache Cache
  | NoOp
