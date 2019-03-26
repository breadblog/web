module Style.Screen exposing (Screen, showOn, hideOn, notPhone, base, highRes, large, med, phone, small)

import Css exposing (Style, px)
import Css.Media as Media exposing (only, screen, withMedia)


type alias Screen = List Style -> Style


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
large =
    withMedia [ only screen [ Media.minWidth (px 1601), Media.maxWidth (px 2400) ] ]


highRes : List Style -> Style
highRes styles =
    withMedia [ only screen [ Media.minWidth (px 2401) ] ]
        styles


screens : List Screen
screens =
    [ phone
    , small
    , med
    , base
    , large
    , highRes
    ]


notPhone : List Screen
notPhone =
    List.filter
        (\s -> s /= phone)
        screens



-- TODO: Adjust implementation of these to not use "initial" without performing function equality
-- Might make sense to move to a more Data sense approach
-- i.e screens are concrete types that are mapped to the functions in a dict
-- this way we can perform these comparisons w/o breaking the webpage
-- Means we would need helper functions to perform the Screen.phone [ myPhoneStyles ]

-- Screen.style : List Screen.Screen -> List Style -> Style


{-

rework these breakpoints (probably can be fewer?)
type Screen
    = Phone
    | Tablet
    | SmallDesktop
    | MediumDesktop
    | LargeDesktop
    | HighResDesktop


style : Screen -> List Style -> Style
style screen =
    case screen of
        Phone ->
            withMedia [ only screen [ Media.maxWidth (px 400) ] ]

        ...


Now we have comparable values (Screen) that we can use for more sophisticated functions like showOn
-}


showOn : List (List Style -> Style) -> Style
showOn shown =
    let
        hidden =
            List.filter
                (\s -> List.member s screens)
                shown
    in
    hideOn hidden


hideOn : List (List Style -> Style) -> Style
hideOn hidden =
    hidden
        |> List.map (\s -> s [ Css.display Css.none ])
        |> Css.batch
