module Page.Donate exposing (view)

import Css exposing (..)
import Data.Cache as Cache exposing (Cache)
import Data.General as General exposing (General)
import Data.Route as Route exposing (Route(..))
import Data.Session as Session exposing (Session)
import Data.Theme exposing (Theme)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href)
import Html.Styled.Events exposing (onClick)



-- View


view : General -> Html msg
view general =
    let
        cache =
            General.cache general

        theme =
            Cache.theme cache
    in
    div
        [ class (Route.toClass Donate) ]
        []
