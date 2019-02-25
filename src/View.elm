module View exposing (view)

import Browser exposing (Document)
import Css exposing (..)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Message exposing (Msg)
import Model exposing (Route(..), Model)
import Style.Global
import Page.Fork
import Page.NotFound
import Page.DarkPost
import Style.Theme as Theme


view : Model -> Document Msg
view model =
    { title = "Bits n' Bites"
    , body = List.map toUnstyled (body model)
    }


body : Model -> List (Html Msg)
body model =
    [ div
        [ class "app"
        , css
            [ position absolute
            , top (px 0)
            , bottom (px 0)
            , left (px 0)
            , right (px 0)
            , backgroundColor (Theme.background model.cache)
            , color (Theme.primaryFont model.cache)
            ]
        ]
        [ page model ]
    , Style.Global.style
    ]


page : Model -> Html Msg
page model =
    case model.route of
        Fork ->
            Page.Fork.view model

        DarkPost _ ->
            Page.DarkPost.view model

        _ ->
            Page.NotFound.view model
