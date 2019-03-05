module View.Footer exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Model exposing (Model, Route(..))
import Message exposing (Msg)
import Style.Theme as Theme
import View.Svg as Svg
import Svg.Styled.Attributes as SvgAttr

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
            , backgroundColor (Theme.primary model.cache)
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
            text model.cache.version
        ]

footerRight : Model -> Html Msg
footerRight model =
    div
        [ css
            [ margin (px 10)
            ]
        ]
        [
            Svg.github [
                SvgAttr.css [
                    margin (px 5)
                ]
            ],
            Svg.linkedin [
                SvgAttr.css [
                    margin (px 5)
                ]
            ]
        ]