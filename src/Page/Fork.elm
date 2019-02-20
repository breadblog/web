module Page.Fork exposing (view)


import Html
import Html.Styled exposing (Html, main_, div, span)
import Html.Styled.Attributes exposing (class, css)
import Html.Styled.Events exposing (onClick)
import Css exposing (..)
import Model exposing (Model)
import Message exposing (Msg)
import Nav exposing (Route(..), routeToClass)


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
            ]
        ]


darkContainer : Html Msg
darkContainer =
    div [] []


princessAngelQueenContainer : Html Msg
princessAngelQueenContainer =
    div [] []
