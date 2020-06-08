module Page.NotFound exposing (view)

import Data.Context exposing (Context)
import Data.Route as Route exposing (Route(..))
import Html.Styled exposing (Html, main_)
import Html.Styled.Attributes exposing (class)



-- Message --


view : Context -> List (Html msg)
view _ =
    [ main_
        [ class (Route.toClass NotFound)
        ]
        []
    ]
