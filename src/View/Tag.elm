module View.Tag exposing (view)


import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (onClick)
import Css exposing (..)
import Data.Tag as Tag exposing (Tag)


view : msg -> Tag -> Html msg
view msg tag =
    div
        [ class "tag"
        , onClick msg
        , css
            []
        ]
        [ text <| Tag.name tag ]
