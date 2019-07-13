module Style.Color exposing (accent, background, card, cardHeading, danger, drawer, dropdown, dropdownActive, dropdownContrast, favorite, overlay, primary, primaryFont, secondary, secondaryFont, slothBackground, tagBackground, tertiaryFont)

import Css exposing (..)
import Data.Theme exposing (Theme(..))



-- Core colors


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
            hex "616161"

        Light ->
            hex ""


accent : Theme -> Color
accent theme =
    case theme of
        Dark ->
            hex "424242"

        Light ->
            hex ""



-- Element Specific


card : Theme -> Color
card theme =
    case theme of
        Dark ->
            hex "484848"

        Light ->
            hex "fff"


cardHeading : Theme -> Color
cardHeading theme =
    case theme of
        Dark ->
            rgba 33 33 33 0.8

        Light ->
            hex "fff"


drawer : Theme -> Color
drawer theme =
    dropdown theme


dropdown : Theme -> Color
dropdown theme =
    case theme of
        Dark ->
            hex "111111"

        Light ->
            hex "fff"


dropdownContrast : Theme -> Color
dropdownContrast theme =
    case theme of
        Dark ->
            hex "fff"

        Light ->
            hex "000"


dropdownActive : Theme -> Color
dropdownActive theme =
    case theme of
        Dark ->
            hex "000"

        Light ->
            hex "fff"


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


tertiaryFont : Theme -> Color
tertiaryFont theme =
    case theme of
        Dark ->
            rgba 255 255 255 0.5

        Light ->
            rgba 0 0 0 0.5


danger : Theme -> Color
danger theme =
    case theme of
        Dark ->
            hex "FF5252"

        Light ->
            hex "b71c1c"


overlay : Theme -> Color
overlay theme =
    rgba 0 0 0 0.4


slothBackground : Color
slothBackground =
    hex "003240"


tagBackground : Theme -> Color
tagBackground theme =
    case theme of
        Dark ->
            hex "171212"

        Light ->
            hex "fff"


favorite : Color
favorite =
    hex "FF0000"
