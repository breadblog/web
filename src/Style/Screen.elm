module Style.Screen exposing (base, highRes, large, med, phone, small)

import Css exposing (Style, px)
import Css.Media as Media exposing (only, screen, withMedia)


phone : List Style -> Style
phone styles =
    withMedia [ only screen [ Media.maxWidth (px 400) ] ]
        styles


small : List Style -> Style
small styles =
    withMedia [ only screen [ Media.minWidth (px 401), Media.maxWidth (px 800) ] ]
        styles


med : List Style -> Style
med styles =
    withMedia [ only screen [ Media.minWidth (px 801), Media.maxWidth (px 1200) ] ]
        styles


base : List Style -> Style
base styles =
    withMedia [ only screen [ Media.minWidth (px 1201), Media.maxWidth (px 1600) ] ]
        styles


large : List Style -> Style
large styles =
    withMedia [ only screen [ Media.minWidth (px 1601), Media.maxWidth (px 2400) ] ]
        styles


highRes : List Style -> Style
highRes styles =
    withMedia [ only screen [ Media.minWidth (px 2401) ] ]
        styles
