module Page.Redirect exposing (view)

import Css exposing (..)
import Data.Theme exposing (Theme)
import Html.Styled exposing (Html, main_)
import Html.Styled.Attributes exposing (class, css)
import Style.Theme as Theme
import Data.Cache as Cache exposing (Cache)
import Data.Session as Session exposing (Session)


-- Model


view : (Session, Cache) -> Html msg
view (session, cache) =
    let
        theme =
            Cache.theme cache

    in
    main_
        [ css
            [ backgroundColor <| Theme.background theme
            , height <| pct 100
            , width <| pct 100
            ]
        , class "redirect"
        ]
        []
