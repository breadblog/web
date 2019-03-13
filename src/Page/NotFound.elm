module Page.NotFound exposing (view)

import Css
import Data.Session exposing (Session)
import Html
import Html.Styled exposing (Html, main_)
import Html.Styled.Attributes exposing (class)
import Html.Styled.Events exposing (onClick)
import Message exposing (Msg)
import Data.Cache as Cache exposing (Cache)
import Data.Session as Session exposing (Session)
import Data.Route as Route exposing (Route(..))



view : (Session, Cache) -> Html Msg
view (session, cache) =
    main_
        [ class (Route.toClass NotFound)
        ]
        []
