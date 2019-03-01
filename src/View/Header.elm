module View.Header exposing (view)


import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Css exposing (..)
import Css.Media as Media exposing (withMedia, only, screen)
import Message exposing (Msg)
import Model exposing (Model, Route(..))
import Style.Theme as Theme
import Svg.Styled.Attributes
import View.Svg as Svg
import Style.Font as Font
import Nav exposing (routeToPath)
import Style.Screen as Screen


view : Model -> Html Msg
view model =
    header
        [ css
            [ displayFlex
            , flexDirection row
            , alignItems center
            , Css.height (px 60)
            , Css.width (pct 100)
            , backgroundColor (Theme.primary model.cache)
            ]
        ]
        [ headerLeft model
        , searchBar model
        , headerRight model
        ]


-- Left Side


headerLeft : Model -> Html Msg
headerLeft model =
    div
        [ css
            [ headerSideStyle
            ]
        ]
        [ logo
        , filters model
        , spacer
            <| List.map
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


filters : Model -> Html Msg
filters model =
    div
        [ class "filters"
        , css
            [ displayFlex
            , flexDirection row
            ]
        ]
        [ dropdown model "tags"
        , dropdown model "author"
        ]


-- Search Bar


searchBar : Model -> Html Msg
searchBar model =
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
                [ Screen.medScreen, Screen.smallScreen, Screen.phoneScreen ] |> batch
            ]
        ]
        [ input
            [ class "search"
            , css
                [ flexGrow (num 1)
                , borderWidth (px 0)
                , outline none
                , backgroundColor (Theme.accent model.cache)
                , color (Theme.secondaryFont model.cache)
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
                , Css.color (Theme.secondaryFont model.cache)
                ]
            ]
        ]


searchResults : Model -> Html Msg
searchResults model =
    text ""


searchOverlay : Html Msg
searchOverlay =
    text ""

-- Right Side


headerRight : Model -> Html Msg
headerRight model =
    div
        [ css
            [ headerSideStyle
            ]
        ]
        [ spacer []
        , menu model
        , profile model
        ]


menu : Model -> Html Msg
menu model =
    div
        [ css
            [ displayFlex
            , flexDirection row
            , Css.height (pct 100)
            , alignItems center
            ]
        ]
        [ dropdown model "theme"
        , navLink model "about" About
        , navLink model "donate" Donate
        ]


profile : Model -> Html Msg
profile model =
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
                    [ Css.color (Theme.secondaryFont model.cache)
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
                    [ Css.color (Theme.secondaryFont model.cache)
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
spacer styles = div
    [ class "spacer"
    , css styles
    ]
    []


navLink : Model -> String -> Route -> Html Msg
navLink model name route =
    div
        [ class "nav-link"
        , css
            [ spacing Right
            ]
        ]
        [ a
            [ css
                [ textDecoration none
                , color (Theme.secondaryFont model.cache)
                , fontSize (rem 1.5)
                , fontWeight (int 300)
                ]
            , href (routeToPath route)
            ]
            [ text name ]
        ]



dropdown : Model -> String -> Html Msg
dropdown model name =
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
                , color (Theme.secondaryFont model.cache)
                ]
            ]
            [ text name ]
        , Svg.chevronDown
            [ Svg.Styled.Attributes.css
                [ Css.color (Theme.secondaryFont model.cache)
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
