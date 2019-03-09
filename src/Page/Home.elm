module Page.Fork exposing (view)

import Css exposing (..)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href)
import Html.Styled.Events exposing (onClick)
import Message exposing (Msg(..))
import Nav exposing (routeToClass)


view : Html Msg
view =
    text ""
