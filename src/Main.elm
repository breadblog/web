module Main exposing (main)

import Browser
import Init exposing (init)
import Json.Decode exposing (Value)
import Message exposing (Msg(..))
import Port
import Subscription exposing (subscriptions)
import Update exposing (update)
import View exposing (view)
import Data.Session exposing (Session)


-- Model

type Model
    = NotFound Session
    | Home Session
    | Post Session
    | Profile Session
    | Login Session
    | Problem ProblemInfo


type alias ProblemInfo =
    {}


-- Program


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
