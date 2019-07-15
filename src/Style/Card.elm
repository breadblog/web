module Style.Card exposing (headingStyle, style)

import Css exposing (..)
import Data.Theme exposing (Theme)
import Style.Color as Color


style : Theme -> Style
style theme =
    Css.batch
        [ backgroundColor <| Color.card theme
        , borderRadius <| cardRadius
        ]


headingStyle : Theme -> Style
headingStyle theme =
    Css.batch
        [ borderRadius4 cardRadius cardRadius (pct 0) (pct 0)
        , displayFlex
        , Css.height <| px 40
        , backgroundColor <| Color.cardHeading theme
        , alignItems center
        ]


cardRadius : Px
cardRadius =
    px 5
