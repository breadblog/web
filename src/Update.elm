module Update exposing (update)


import Browser
import Browser.Navigation as Nav
import Url
import Message exposing (Msg(..))
import Model exposing (Model, Cache)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of

        NoOp ->
            ( model, Cmd.none )

        LinkClicked urlRequest ->
          case urlRequest of
            Browser.Internal url ->
              ( model, Nav.pushUrl model.key (Url.toString url) )

            Browser.External href ->
              ( model, Nav.load href )

        UrlChanged url ->
          ( { model | url = url }
          , Cmd.none
          )
