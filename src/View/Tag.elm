module View.Tag exposing (view)

import Css exposing (..)
import Data.Tag as Tag exposing (Tag)
import Data.Theme as Theme exposing (Theme)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (onClick)
import Style.Color as Color


view : Theme -> List (Attribute msg) -> Tag -> Html msg
view theme attributes tag =
    div
        (List.append
            [ class "tag"
            , css
                [ backgroundColor <| Color.tagBackground theme
                , color <| Color.tertiaryFont theme
                , padding2 (px 4) (px 8)
                , margin2 (px 0) (px 5)
                , borderRadius (px 25)
                ]
            ]
            attributes
        )
        [ text <| Tag.getName tag ]
