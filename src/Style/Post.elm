module Style.Post exposing (style)

import Css exposing (..)
import Css.Global exposing (Snippet)
import Data.Theme exposing (Theme(..))
import Style.Color as Color
import Style.Font exposing (firaCode)


style : Theme -> List Snippet
style theme =
    case theme of
        Dark ->
            darkPostStyle

        Light ->
            lightPostStyle


darkPostStyle : List Snippet
darkPostStyle =
    [ Css.Global.h1
        [ fontSize (rem 1.5)
        ]
    , Css.Global.h2
        [ fontSize (rem 1.4)
        ]
    , Css.Global.h3
        [ fontSize (rem 1.3)
        ]
    , Css.Global.h4
        [ fontSize (rem 1.2)
        ]
    , Css.Global.h5
        [ fontSize (rem 1.1)
        ]
    , Css.Global.code
        [ fontFamilies firaCode
        ]
    , Css.Global.p
        [ Css.Global.descendants
            -- Inline code
            [ Css.Global.code
                []
            ]
        ]

    -- Code block containers
    , Css.Global.pre
        [ Css.Global.descendants
            [ Css.Global.code
                [ borderRadius (px 5)
                , display block
                , overflowX auto
                , padding <| em 0.5
                , backgroundColor <| rgba 40 40 40 0.9
                ]
            ]
        ]
    ]


lightPostStyle : List Snippet
lightPostStyle =
    []
