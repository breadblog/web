module Style.Button exposing (default, submit)


import Css exposing (..)
import Css.Transitions as Transitions exposing (transition)
import Style.Font as Font
import Style.Shadow as Shadow
import Style.Color as Color
import Data.Theme exposing (Theme(..))


default : Style
default =
    Css.batch
        [ padding <| px 7
        , fontFamilies Font.montserrat
        , borderRadius <| px 4
        , fontSize <| rem 1
        , fontWeight (int 500)
        , Shadow.dp2
        , border <| px 0
        , color <| Color.secondaryFont Dark
        , cursor pointer
        , transition
            [ Transitions.boxShadow 300 ]
        , hover
            [ Shadow.dp4 ]
        ]


submit : Style
submit =
    Css.batch
        [ backgroundColor <| hex "006400"
        ]
