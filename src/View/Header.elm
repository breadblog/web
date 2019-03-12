module View.Header exposing (view)

import Css exposing (..)
import Css.Media as Media exposing (only, screen, withMedia)
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Html.Styled.Events exposing (onClick)
import Message exposing (Msg(..))
import Data.Theme exposing (Theme(..))
import Data.Route as Route exposing (Route(..))
import Data.Cache as Cache exposing (Msg(..))
import Style.Font as Font
import Style.Screen as Screen
import Style.Theme as Theme
import Svg.Styled.Attributes
import View.Svg as Svg


type alias Msg = Message.Msg


view : Theme -> Html Msg
view theme =
    header
        [ css
            [ displayFlex
            , flexDirection row
            , alignItems center
            , Css.height (px 60)
            , Css.width (pct 100)
            , backgroundColor (Theme.primary theme)
            ]
        ]
        [ headerLeft theme
        , searchBar theme
        , headerRight theme
        ]



-- Left Side


headerLeft : Theme -> Html Msg
headerLeft theme =
    div
        [ css
            [ headerSideStyle
            ]
        ]
        [ logo
        , filters theme
        , spacer <|
            List.map
                (\f -> f [ display none ])
                [ Screen.medScreen, Screen.smallScreen, Screen.phoneScreen ]
        ]


logo : Html Msg
logo =
    h1
        [ css
            [ fontFamilies Font.indieFlower
            , fontWeight normal
            , marginLeft (px edgeMargin)
            ]
        ]
        [ text "Bits n' Bites"
        ]


filters : Theme -> Html Msg
filters theme =
    div
        [ class "filters"
        , css
            [ displayFlex
            , flexDirection row
            ]
        ]
        [ dropdown theme "tags"
        , dropdown theme "author"
        ]



-- Search Bar


searchBar : Theme -> Html Msg
searchBar theme =
    div
        [ class "search"
        , css
            [ displayFlex
            , flexDirection row
            , position relative
            , Css.height (px 36)
            , Css.width (px 260)
            , List.map
                (\f -> f [ display none ])
                [ Screen.medScreen, Screen.smallScreen, Screen.phoneScreen ]
                |> batch
            ]
        ]
        [ input
            [ class "search"
            , css
                [ flexGrow (num 1)
                , borderWidth (px 0)
                , outline none
                , backgroundColor (Theme.accent theme)
                , color (Theme.secondaryFont theme)
                , paddingLeft (px 11)
                , fontSize (rem 1)
                , fontFamilies Font.montserrat
                ]
            ]
            []
        , Svg.search
            [ Svg.Styled.Attributes.css
                [ position absolute
                , right (px 0)
                , Css.height (px 18)
                , Css.width (px 18)
                , alignSelf center
                , marginRight (px 8)
                , Css.color (Theme.secondaryFont theme)
                ]
            ]
        ]


searchResults : Theme -> Html Msg
searchResults theme =
    text ""


searchOverlay : Html Msg
searchOverlay =
    text ""



-- Right Side


headerRight : Theme -> Html Msg
headerRight theme =
    div
        [ css
            [ headerSideStyle
            ]
        ]
        [ spacer []
        , menu theme
        , profile theme
        ]


menu : Theme -> Html Msg
menu theme =
    div
        [ css
            [ displayFlex
            , flexDirection row
            , Css.height (pct 100)
            , alignItems center
            ]
        ]
        [ dropdown theme "theme"
        , navLink theme "about" About
        , navLink theme "donate" Donate
        ]


profile : Theme -> Html Msg
profile theme =
    let
        iconSize =
            28

        chevronSize =
            20
    in
    div
        [ class "profile"
        , css
            [ Css.height (pct 100)
            , displayFlex
            , flexDirection row
            , marginRight (px edgeMargin)
            ]
        ]
        [ Svg.user
            [ Svg.Styled.Attributes.css
                [ Css.color (Theme.secondaryFont theme)
                , position relative
                , top (px 3)
                , Css.width (px iconSize)
                , Css.height (px iconSize)
                , alignSelf center
                , right (px 0)
                , marginLeft (px 10)
                , bottom (px 10)
                ]
            ]
        , Svg.chevronDown
            [ Svg.Styled.Attributes.css
                [ Css.color (Theme.secondaryFont theme)
                , Css.height (px chevronSize)
                , Css.width (px chevronSize)
                , alignSelf center
                , position relative
                , top (px 2)
                ]
            ]
        ]



-- Common


headerSideStyle : Style
headerSideStyle =
    batch
        [ flexGrow (num 1)
        , Css.width (px 0)
        , Css.height (pct 100)
        , flexBasis auto
        , displayFlex
        , flexDirection row
        , justifyContent spaceBetween
        , alignItems center
        ]


spacer : List Style -> Html Msg
spacer styles =
    div
        [ class "spacer"
        , css styles
        ]
        []


navLink : Theme -> String -> Route -> Html Msg
navLink theme name route =
    div
        [ class "nav-link"
        , css
            [ spacing Right
            ]
        ]
        [ a
            [ css
                [ textDecoration none
                , color (Theme.secondaryFont theme)
                , fontSize (rem 1.5)
                , fontWeight (int 300)
                ]
            , href (Route.toPath route)
            ]
            [ text name ]
        ]


dropdown : Theme -> String -> Html Msg
dropdown theme name =
    div
        [ class "dropdown"
        , css
            [ position relative
            , displayFlex
            , Css.height (pct 100)
            , alignItems center
            , spacing Right
            ]
        ]
        [ h2
            [ css
                [ fontWeight (int 300)
                , fontSize (rem 1.5)
                , color (Theme.secondaryFont theme)
                ]
            ]
            [ text name ]
        , Svg.chevronDown
            [ Svg.Styled.Attributes.css
                [ Css.color (Theme.secondaryFont theme)
                , position relative
                , top (px 3)
                , Css.width (px 20)
                , Css.height (px 20)
                , alignSelf center
                , right (px 0)
                , marginLeft (px 10)
                ]
            ]
        ]


edgeMargin : Float
edgeMargin =
    25


type Side
    = Right
    | Left


spacing : Side -> Style
spacing side =
    let
        spaceStyle =
            case side of
                Left ->
                    marginLeft

                Right ->
                    marginRight
    in
    batch
        [ Screen.smallScreen [ spaceStyle (px 15) ]
        , Screen.medScreen [ spaceStyle (px 20) ]
        , Screen.baseScreen [ spaceStyle (px 25) ]
        , Screen.largeScreen [ spaceStyle (px 30) ]
        , Screen.highResScreen [ spaceStyle (px 45) ]
        ]
