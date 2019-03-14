module View.Footer exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Message exposing (Msg)
import Data.Theme exposing (Theme)
import Data.Version exposing (Version)
import Style.Theme as Theme
import View.Svg as Svg
import Svg.Styled.Attributes as SvgAttr

type alias Model =
    { theme : Theme
    , version : Version
    }

view : Model -> Html Msg
view model =
    footer
        [ css
            [ displayFlex
            , flexDirection row
            , alignItems center
            , justifyContent spaceBetween
            , Css.height (px 60)
            , Css.width (pct 100)
            , backgroundColor (Theme.primary model.theme)
            ]
        ]
        [
            footerLeft model,
            footerRight model
        ]

footerLeft : Model -> Html Msg
footerLeft model =
    div
        [ css
            [ margin (px 10)
            ]
        ]
        [
            text <| Data.Version.toString model.version
        ]

footerRight : Model -> Html Msg
footerRight model =
    div
        [ css
            [ margin (px 10)
            ]
        ]
        (List.map
            (\x -> a [
                href x.path,
                Attr.target "_blank",
                css [
                    textDecoration none,
                    color inherit
                ]
            ][
                x.icon [
                SvgAttr.css [
                    margin (px 5)
                ]
                ]
            ])
            [
                {
                    icon = Svg.github,
                    path = "https://www.google.com"
                },
                {
                    icon = Svg.linkedin,
                    path = "https://www.google.com"
                }
            ]
        )
