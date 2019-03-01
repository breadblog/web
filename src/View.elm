module View exposing (view)

import Browser exposing (Document)
import Css exposing (..)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Message exposing (Msg)
import Model exposing (Model, Route(..))
import Page.DarkPost
import Page.Home
import Page.NotFound
import Style.Global
import Style.Theme as Theme
import Style.Font as Font


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
            , fontFamilies Font.montserrat
            ]
        ]
        [ page model ]
    , Style.Global.style
    ]


page : Model -> Html Msg
page model =
    case model.route of
        Home ->
            Page.Home.view model

        _ ->
            Page.NotFound.view model
