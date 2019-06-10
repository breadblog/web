module Page.Problems exposing (view)

import Css exposing (..)
import Data.General exposing (Msg)
import Data.Problem as Problem exposing (Problem)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (onClick)


view : List (Problem Msg) -> Html Msg
view problems =
    div
        [ class "problems" ]
        [ text "problem page" ]
