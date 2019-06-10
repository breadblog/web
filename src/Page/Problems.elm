module Page.Problems exposing (view)


import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (onClick)
import Data.Problem as Problem exposing (Problem)
import Data.General exposing (Msg)

view : List (Problem Msg) -> Html Msg
view problems =
    div
        [ class "problems" ]
        [ text "problem page" ]
