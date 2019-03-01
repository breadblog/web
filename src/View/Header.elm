module View.Header exposing (view)


import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Css exposing (..)
import Message exposing (Msg)
import Model exposing (Model)
import Style.Theme as Theme
import Svg.Styled.Attributes
import View.Svg as Svg
import Style.Font as Font


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
        ]


headerRight : Model -> Html Msg
headerRight model =
    div
        [ css
            [ headerSideStyle
            ]
        ]
        []


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


spacer : Html Msg
spacer = div [ class "spacer" ] []


logo : Html Msg
logo =
    h1
        [ css
            [ fontFamilies Font.indieFlower
            , fontWeight normal
            , marginLeft (px 30)
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
        [ filter model "tags"
        , filter model "author"
        ]


filter : Model -> String -> Html Msg
filter model name =
    div
        [ class "filter"
        , css
            [ position relative
            , displayFlex
            , Css.height (pct 100)
            , alignItems center
            , marginRight (px 30)
            ]
        ]
        [ h2
            [ css
                [ fontWeight (int 300)
                , fontSize (rem 1.5)
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


menu : Model -> Html Msg
menu model =
    div [] []
