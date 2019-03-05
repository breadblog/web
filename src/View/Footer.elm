module View.Footer exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Model exposing (Model, Route(..))
import Message exposing (Msg)
import Style.Theme as Theme

view : Model -> Html Msg
view model =
    footer
        [ css
            [ displayFlex
            , flexDirection row
            , alignItems center
            , Css.height (px 60)
            , Css.width (pct 100)
            , backgroundColor (Theme.primary model.cache)
            ]
        ]
        [
            text "hi"
        ]
