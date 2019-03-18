module View.Search exposing (view)


import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Svg.Styled
import Message exposing (Msg(..))
import Data.Theme as Theme exposing (Theme)
import Style.Screen as Screen


view : Html Msg
view =
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
