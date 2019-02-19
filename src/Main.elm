import Browser
import Json.Decode exposing (Value)
import Model exposing (Model)
import Message exposing (Msg(..))
import Init exposing (init)
import View exposing (view)
import Update exposing (update)
import Subscription exposing (subscriptions)
import Port


-- TODO: Replace build.sh w/ Dockerfile
-- TODO: Use similar build process as Rust


-- MAIN


main : Program Value Model Msg
main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlChange = UrlChanged
    , onUrlRequest = LinkClicked
    }
