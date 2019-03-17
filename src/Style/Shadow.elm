module Style.Shadow exposing (dp1, dp12, dp16, dp2, dp24, dp3, dp4, dp6, dp8, dp9)

import Css exposing (..)



-- /* Shadow 1dp */


dp1 : Style
dp1 =
    Css.batch
        [ boxShadow5 (px 0) (px 1) (px 1) (px 0) color1
        , boxShadow5 (px 0) (px 2) (px 1) (px -1) color2
        , boxShadow5 (px 0) (px 1) (px 3) (px 0) color3
        ]



-- /* Shadow 2dp */


dp2 : Style
dp2 =
    Css.batch
        [ boxShadow5 (px 0) (px 2) (px 2) (px 0) color1
        , boxShadow5 (px 0) (px 3) (px 1) (px -2) color2
        , boxShadow5 (px 0) (px 1) (px 5) (px 0) color3
        ]



-- /* Shadow 3dp */


dp3 : Style
dp3 =
    Css.batch
        [ boxShadow5 (px 0) (px 3) (px 4) (px 0) color1
        , boxShadow5 (px 0) (px 3) (px 3) (px -2) color2
        , boxShadow5 (px 0) (px 1) (px 8) (px 0) color3
        ]



-- /* Shadow 4dp */


dp4 : Style
dp4 =
    Css.batch
        [ boxShadow5 (px 0) (px 4) (px 5) (px 0) color1
        , boxShadow5 (px 0) (px 1) (px 10) (px 0) color2
        , boxShadow5 (px 0) (px 2) (px 4) (px -1) color3
        ]



-- /* Shadow 6dp */


dp6 : Style
dp6 =
    Css.batch
        [ boxShadow5 (px 0) (px 6) (px 10) (px 0) color1
        , boxShadow5 (px 0) (px 1) (px 18) (px 0) color2
        , boxShadow5 (px 0) (px 3) (px 5) (px -1) color3
        ]



-- /* Shadow 8dp */


dp8 : Style
dp8 =
    Css.batch
        [ boxShadow5 (px 0) (px 8) (px 10) (px 1) color1
        , boxShadow5 (px 0) (px 3) (px 14) (px 2) color2
        , boxShadow5 (px 0) (px 5) (px 5) (px -3) color3
        ]



-- /* Shadow 9dp */


dp9 : Style
dp9 =
    Css.batch
        [ boxShadow5 (px 0) (px 9) (px 12) (px 1) color1
        , boxShadow5 (px 0) (px 3) (px 16) (px 2) color2
        , boxShadow5 (px 0) (px 5) (px 6) (px -3) color3
        ]



-- /* Shadow 12dp */


dp12 : Style
dp12 =
    Css.batch
        [ boxShadow5 (px 0) (px 1) (px 17) (px 2) color1
        , boxShadow5 (px 0) (px 5) (px 22) (px 4) color2
        , boxShadow5 (px 0) (px 7) (px 8) (px -4) color3
        ]



-- /* Shadow 16dp */


dp16 : Style
dp16 =
    Css.batch
        [ boxShadow5 (px 0) (px 1) (px 24) (px 2) color1
        , boxShadow5 (px 0) (px 6) (px 30) (px 5) color2
        , boxShadow5 (px 0) (px 8) (px 10) (px -5) color3
        ]



-- /* Shadow 24dp */


dp24 : Style
dp24 =
    Css.batch
        [ boxShadow5 (px 0) (px 2) (px 38) (px 3) color1
        , boxShadow5 (px 0) (px 9) (px 46) (px 8) color2
        , boxShadow5 (px 0) (px 11) (px 15) (px -7) color3
        ]


color1 : Color
color1 =
    rgba 0 0 0 0.14


color2 : Color
color2 =
    rgba 0 0 0 0.12


color3 : Color
color3 =
    rgba 0 0 0 0.2
