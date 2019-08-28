module Page.Changelog exposing (view)

import Css exposing (..)
import Data.General as General exposing (General)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href)
import Html.Styled.Events exposing (onClick)
import View.Page as Page



-- View --


view : General -> Page.ViewResult msg
view general =
    Page.viewSimple general viewChangelog


viewChangelog : General -> Internals -> List (Html (Compound m))
viewChangelog _ _ =
    [ main_
        [ css
            [ flexGrow <| num 1 ]
        ]
        []
    ]
