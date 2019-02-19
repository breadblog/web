module Main exposing (main)

import Browser
import Init exposing (init)
import Json.Decode exposing (Value)
import Message exposing (Msg(..))
import Model exposing (Model)
import Port
import Subscription exposing (subscriptions)
import Update exposing (update)
import View exposing (view)



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
