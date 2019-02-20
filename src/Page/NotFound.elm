module Page.NotFound exposing (view)


import Html
import Html.Styled exposing (Html, main_)
import Html.Styled.Attributes exposing (class)
import Html.Styled.Events exposing (onClick)
import Css
import Model exposing (Model)
import Message exposing (Msg)
import Nav exposing (Route(..), routeToClass)


view : Model -> Html Msg
view model =
    main_
        [ class (routeToClass NotFound)
        ]
        [
        ]
