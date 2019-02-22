module Page.Fork exposing (view)

import Css exposing (..)
import Html
import Html.Styled exposing (Html, div, main_, span, a, text)
import Html.Styled.Attributes exposing (class, css, href)
import Html.Styled.Events exposing (onClick)
import Message exposing (Msg)
import Model exposing (Route(..), Model)
import Nav exposing (routeToClass)


view : Model -> Html Msg
view model =
    main_
        [ class (routeToClass Fork)
        ]
        [ div
            [ css
                [ displayFlex
                , flexDirection row
                ]
            ]
            [ darkContainer
            , princessAngelQueenContainer
            , a [ href "/bits/post/test-ing" ] [ text "click me!" ]
            ]
        ]


darkContainer : Html Msg
darkContainer =
    div [] []


princessAngelQueenContainer : Html Msg
princessAngelQueenContainer =
    div [] []
