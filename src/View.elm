module View exposing (view)

import Browser exposing (Document)
import Css exposing (..)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Message exposing (Msg)
import Model exposing (Model)
import Nav exposing (Route(..))
import Page.Fork
import Page.NotFound


view : Model -> Document Msg
view model =
    { title = "Bits n' Bites"
    , body = List.map toUnstyled (body model)
    }


body : Model -> List (Html Msg)
body model =
    []


page : Model -> Html Msg
page model =
    case model.route of
        Fork ->
            Page.Fork.view model

        _ ->
            Page.NotFound.view model
