module Page.NotFound exposing (view)

import Css
import Html
import Html.Styled exposing (Html, main_)
import Html.Styled.Attributes exposing (class)
import Html.Styled.Events exposing (onClick)
import Message exposing (Msg)
import Nav exposing (routeToClass)
import Data.Session exposing (Session)
import Data.Route exposing (Route(..))


view : Html Msg
view =
    main_
        [ class (routeToClass NotFound)
        ]
        []
