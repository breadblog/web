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
        ]


full : Style
full =
    batch
        [ margin <| px 0
        , height <| pct 100
        , width <| pct 100
        ]
