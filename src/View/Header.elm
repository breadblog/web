module View.Header exposing (view)


import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Css exposing (..)
import Message exposing (Msg)
import Model exposing (Model)
import Style.Theme as Theme
import Svg.Styled.Attributes
import View.Svg as Svg


view : Model -> Html Msg
view model =
    header
        [ css
            [ displayFlex
            , flexDirection row
            , justifyContent spaceBetween
            , alignItems center
            , Css.height (px 60)
            , Css.width (pct 100)
            , backgroundColor (Theme.primary model.cache)
            ]
        ]
        [ logo
        , searchBar model
        , menu model
        ]


logo : Html Msg
logo =
    div [] []


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
