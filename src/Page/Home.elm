module Page.Home exposing (view)

import Css exposing (..)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href)
import Html.Styled.Events exposing (onClick)
import Message exposing (Msg(..))
import Model exposing (Model, Route(..))
import Nav exposing (routeToClass)
import View.Header


view : Model -> Html Msg
view model =
    div
        [ class (routeToClass Home) ]
        [ View.Header.view model
        , main_
            []
            []
        ]
