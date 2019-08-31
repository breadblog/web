module Page.NotFound exposing (view)

import Css exposing (..)
import Data.General as General exposing (General)
import Data.Route as Route exposing (Route(..))
import Html
import Html.Styled exposing (Html, main_)
import Html.Styled.Attributes exposing (class, css)
import Html.Styled.Events exposing (onClick)



{- View -}


view : General -> List (Html msg)
view general =
    [ main_
        [ class (Route.toClass NotFound)
        , css
            [ flexGrow (num 1) ]
        ]
        []
    ]
