module Page.NotFound exposing (view)

import Css
import Html
import Html.Styled exposing (Html, main_)
import Html.Styled.Attributes exposing (class)
import Html.Styled.Events exposing (onClick)
import Message exposing (Msg)
import Model exposing (Model, Route(..))
import Nav exposing (routeToClass)


view : Model -> Html Msg
view model =
    main_
        [ class (routeToClass NotFound)
        ]
        []
