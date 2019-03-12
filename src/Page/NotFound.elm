module Page.NotFound exposing (view)

import Html
import Html.Styled exposing (Html, main_)
import Html.Styled.Attributes exposing (class)
import Html.Styled.Events exposing (onClick)
import Css
import Data.Route as Route exposing (Route(..))
import Data.Session exposing (Session)
import Message exposing (Msg)


view : Html Msg
view =
    main_
        [ class (Route.toClass NotFound)
        ]
        []
