module Page.Redirect exposing (view)

import Css exposing (..)
import Data.Context as Context exposing (Context)
import Html.Styled exposing (Html, main_)
import Html.Styled.Attributes exposing (class, css)
import Style.Color as Color



-- Model


view : Context -> List (Html msg)
view general =
    let
        theme =
            Context.getTheme general
    in
    [ main_
        [ css
            [ backgroundColor <| Color.background theme
            , height <| pct 100
            , width <| pct 100
            ]
        , class "redirect"
        ]
        []
    ]
