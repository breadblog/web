module Page.Redirect exposing (view)


import Html.Styled exposing (Html, main_)
import Html.Styled.Attributes exposing (css, class)
import Css exposing (..)
import Data.Theme exposing (Theme)
import Style.Theme as Theme


view : Theme -> Html msg
view theme =
    main_
        [ css
            [ backgroundColor <| Theme.background theme
            , height <| pct 100
            , width <| pct 100
            ]
        , class "redirect"
        ]
        []
