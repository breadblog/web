module Style.Card exposing (headingStyle, style)

import Css exposing (..)
import Data.Theme exposing (Theme)
import Style.Color as Color


style : Theme -> Style
style theme =
    Css.batch
        [ backgroundColor <| Color.card theme
        , borderRadius <| cardRadius
        , position relative
        ]


headingStyle : Theme -> Style
headingStyle theme =
    Css.batch
        [ borderRadius4 cardRadius cardRadius (pct 0) (pct 0)
        , displayFlex
        , flex3 (int 0) (int 0) (px 40)
        , Css.width (pct 100)
        , backgroundColor <| Color.cardHeading theme
        , alignItems center
        ]


cardRadius : Px
cardRadius =
    px 5
