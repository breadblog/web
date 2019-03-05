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
import View.Footer


view : Model -> Html Msg
view model =
    div
        [ class (routeToClass Home)
        , css
            [ displayFlex
            , flexDirection column
            , Css.height (pct 100)
            ]
        ]
        [ View.Header.view model
        , main_
            [
                css
                    [ flexGrow (num 1)
                    ]
            ]
            [
                text "hello"
            ]
        , View.Footer.view model
        ]
