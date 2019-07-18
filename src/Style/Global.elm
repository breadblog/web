module Style.Global exposing (style)

import Css exposing (..)
import Css.Animations as Animations exposing (..)
import Css.Global as Global exposing (..)
import Data.Theme exposing (Theme)
import Html.Styled exposing (Html)
import Style.Color as Color
import Style.Dimension as Dimension
import Style.Shadow as Shadow


style : Theme -> Html msg
style theme =
    global
        [ html [ full ]
        , body [ full ]
        , id "app"
            [ displayFlex
            , flexDirection column
            ]
        , class "hidden"
            [ Css.opacity (num 0) ]
        , class "dropdown"
            [ hover
                [ descendants
                    [ class "dropdown-el"
                        [ color <| Color.primaryFont theme
                        ]
                    , class "dropdown-contents"
                        [ maxHeight <| px Dimension.dropdownHeight
                        ]
                    ]
                , Css.backgroundColor <| Color.dropdown theme
                , Shadow.dp6
                ]
            ]
        , class "footer-dropup"
            [ hover
                [ descendants
                    [ selector "svg"
                        [ color <| Color.primaryFont theme ]
                    , class "footer-options"
                        [ display initial ]
                    ]
                ]
            ]
        , typeSelector "*::-webkit-scrollbar"
            [ width (rem 0.8) ]
        , typeSelector "*::-webkit-scrollbar-track"
            [ Css.property "-webkit-box-shadow" "inset 0 0 6px rgba(0, 0, 0, 0.3)" ]
        , typeSelector "*::-webkit-scrollbar-thumb"
            [ Css.backgroundColor (Color.secondary theme)
            , outline3 (px 1) solid (Color.accent theme)
            ]
        ]


full : Style
full =
    batch
        [ margin <| px 0
        , height <| pct 100
        , width <| pct 100
        ]
