module Style.Screen exposing (baseScreen, highResScreen, largeScreen, medScreen, phoneScreen, smallScreen)

import Css exposing (Style, px)
import Css.Media as Media exposing (only, screen, withMedia)


phoneScreen : List Style -> Style
phoneScreen styles =
    withMedia [ only screen [ Media.maxWidth (px 400) ] ]
        styles


smallScreen : List Style -> Style
smallScreen styles =
    withMedia [ only screen [ Media.minWidth (px 401), Media.maxWidth (px 800) ] ]
        styles


medScreen : List Style -> Style
medScreen styles =
    withMedia [ only screen [ Media.minWidth (px 801), Media.maxWidth (px 1200) ] ]
        styles


baseScreen : List Style -> Style
baseScreen styles =
    withMedia [ only screen [ Media.minWidth (px 1201), Media.maxWidth (px 1600) ] ]
        styles


largeScreen : List Style -> Style
largeScreen styles =
    withMedia [ only screen [ Media.minWidth (px 1601), Media.maxWidth (px 2400) ] ]
        styles


highResScreen : List Style -> Style
highResScreen styles =
    withMedia [ only screen [ Media.minWidth (px 2401) ] ]
        styles
