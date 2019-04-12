module Style.Screen exposing (Screen(..), all, desktop, hideOn, mobile, not, showOn, style)

import Css exposing (Style, px)
import Css.Media as Media exposing (only, withMedia)


type Screen
    = Phone
    | Tablet
    | SmallDesktop
    | MediumDesktop
    | LargeDesktop
    | HighResDesktop


all : List Screen
all =
    [ Phone
    , Tablet
    , SmallDesktop
    , MediumDesktop
    , LargeDesktop
    , HighResDesktop
    ]


not : List Screen -> List Screen
not screens =
    let
        ints =
            List.map toInt screens
    in
    List.filter
        (\s -> Basics.not <| List.member (toInt s) ints)
        all


mobile : List Screen
mobile =
    [ Phone
    , Tablet
    ]


desktop : List Screen
desktop =
    not mobile


style : List Screen -> List Style -> Style
style screens styles =
    screens
        |> List.map (\s -> styleOne s styles)
        |> Css.batch


showOn : List Screen -> Style
showOn shown =
    shown
        |> not
        |> hideOn


hideOn : List Screen -> Style
hideOn hidden =
    style hidden [ Css.display Css.none ]



-- Private


-- TODO: How to reliably determine iPad pro vs small laptop?? ie high res vs low res + shit screen
-- TODO: How to test that ALL screen sizes are covered?
styleOne : Screen -> List Style -> Style
styleOne screen =
    case screen of
        Phone ->
            withMedia [ only Media.screen [ Media.maxWidth (px 400) ] ]

        Tablet ->
            withMedia [ only Media.screen [ Media.minWidth (px 401), Media.maxWidth (px 800) ] ]

        SmallDesktop ->
            withMedia [ only Media.screen [ Media.minWidth (px 801), Media.maxWidth (px 1200) ] ]

        MediumDesktop ->
            withMedia [ only Media.screen [ Media.minWidth (px 1201), Media.maxWidth (px 1600) ] ]

        LargeDesktop ->
            withMedia [ only Media.screen [ Media.minWidth (px 1601), Media.maxWidth (px 2400) ] ]

        HighResDesktop ->
            withMedia [ only Media.screen [ Media.minWidth (px 2401) ] ]


toInt : Screen -> Int
toInt screen =
    case screen of
        Phone ->
            1

        Tablet ->
            2

        SmallDesktop ->
            3

        MediumDesktop ->
            4

        LargeDesktop ->
            5

        HighResDesktop ->
            6
