module Page.NotFound exposing (view)

import Css
import Data.Route exposing (Route(..))
import Data.Session exposing (Session)
import Html
import Html.Styled exposing (Html, main_)
import Html.Styled.Attributes exposing (class)
import Html.Styled.Events exposing (onClick)
import Message exposing (Msg)
import Nav exposing (routeToClass)


view : Html Msg
view =
    main_
        [ class (routeToClass NotFound)
        ]
        []
