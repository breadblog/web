module Style.Theme exposing (Themed, accent, background, primary, primaryFont, secondary, secondaryFont)

import Css exposing (..)
import Model exposing (Model, Theme(..))


type alias Themed a =
    { a
        | theme : Theme
    }


background : Themed a -> Color
background { theme } =
    case theme of
        Dark ->
            hex "303030"

        Light ->
            rgb 255 255 255


primary : Themed a -> Color
primary { theme } =
    case theme of
        Dark ->
            hex "212121"

        Light ->
            hex "fff"


secondary : Themed a -> Color
secondary { theme } =
    case theme of
        Dark ->
            hex "302A2A"

        Light ->
            hex ""


accent : Themed a -> Color
accent { theme } =
    case theme of
        Dark ->
            hex "424242"

        Light ->
            hex ""


primaryFont : Themed a -> Color
primaryFont { theme } =
    case theme of
        Dark ->
            rgba 255 255 255 0.85

        Light ->
            rgba 0 0 0 1.0


secondaryFont : Themed a -> Color
secondaryFont { theme } =
    case theme of
        Dark ->
            rgba 255 255 255 0.7

        Light ->
            rgba 0 0 0 1.0
