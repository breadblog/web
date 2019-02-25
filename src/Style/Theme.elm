module Style.Theme exposing (..)


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
            rgb 0 0 0

        Light ->
            rgb 255 255 255


primaryFont : Themed a -> Color
primaryFont { theme } =
    case theme of
        Dark ->
            rgba 255 255 255 0.9

        Light ->
            rgba 0 0 0 1.0
