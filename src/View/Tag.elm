module View.Tag exposing (view)

import Css exposing (..)
import Data.Tag as Tag exposing (Tag)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (onClick)


view : msg -> Tag -> Html msg
view msg tag =
    div
        [ class "tag"
        , onClick msg
        , css
            []
        ]
        [ text <| Tag.name tag ]
