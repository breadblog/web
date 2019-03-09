module Style.Theme exposing (background, primaryFont)

import Css exposing (..)
import Data.Theme exposing (Theme(..))


background : Theme -> Color
background theme =
    case theme of
        Dark ->
            rgb 0 0 0

        Light ->
            rgb 255 255 255


primaryFont : Theme -> Color
primaryFont theme =
    case theme of
        Dark ->
            rgba 255 255 255 0.9

        Light ->
            rgba 0 0 0 1.0
