module Style.Theme exposing (accent, background, primary, primaryFont, secondary, secondaryFont)

import Css exposing (..)
import Data.Theme exposing (Theme(..))


background : Theme -> Color
background theme =
    case theme of
        Dark ->
            hex "303030"

        Light ->
            rgb 255 255 255


primary : Theme -> Color
primary theme =
    case theme of
        Dark ->
            hex "212121"

        Light ->
            hex "fff"


secondary : Theme -> Color
secondary theme =
    case theme of
        Dark ->
            hex "302A2A"

        Light ->
            hex ""


accent : Theme -> Color
accent theme =
    case theme of
        Dark ->
            hex "424242"

        Light ->
            hex ""


primaryFont : Theme -> Color
primaryFont theme =
    case theme of
        Dark ->
            rgba 255 255 255 0.85

        Light ->
            rgba 0 0 0 1.0


secondaryFont : Theme -> Color
secondaryFont theme =
    case theme of
        Dark ->
            rgba 255 255 255 0.7

        Light ->
            rgba 0 0 0 1.0
