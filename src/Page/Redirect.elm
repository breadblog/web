module Page.Redirect exposing (view)

import Css exposing (..)
import Data.Cache as Cache exposing (Cache)
import Data.Session as Session exposing (Session)
import Data.Theme exposing (Theme)
import Html.Styled exposing (Html, main_)
import Html.Styled.Attributes exposing (class, css)
import Style.Color as Color



-- Model


view : ( Session, Cache ) -> Html msg
view ( session, cache ) =
    let
        theme =
            Cache.theme cache
    in
    main_
        [ css
            [ backgroundColor <| Color.background theme
            , height <| pct 100
            , width <| pct 100
            ]
        , class "redirect"
        ]
        []
