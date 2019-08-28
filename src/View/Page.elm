module View.Page exposing (view, viewSimple)

import Data.General as General exposing (General)
import Data.Problem as Problem exposing (Problem)
import Html.Styled exposing (Html)
import View.Footer as Footer
import View.Header as Header


view : General -> model -> (model -> Html msg) -> Html msg
view general model viewPage =
    let
        theme =
            General.theme general

        version =
            General.version general
    in
    List.concat
        [ Header.view general
        , viewPage model
        , Footer.view theme version
        ]


viewSimple : General -> (General -> Html msg) -> Html msg
viewSimple general viewPage =
    let
        theme =
            General.theme general

        version =
            General.version general
    in
    List.concat
        [ Header.view general
        , viewPage general
        , Footer.view theme version
        ]
