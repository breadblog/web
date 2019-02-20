module Update exposing (update)

import Browser
import Browser.Navigation exposing (load, pushUrl)
import Message exposing (Msg(..))
import Model exposing (Cache, Model)
import Nav
import Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, load href )

        UrlChanged url ->
            let
                route =
                    Nav.urlToRoute url
            in
            ( { model | route = route }
            , Cmd.none
            )
