module Style.Post exposing (PostStyle, style)

import Css exposing (..)
import Css.Global exposing (Snippet)
import Data.Theme exposing (Theme(..))
import Style.Color as Color
import Style.Font exposing (firaCode)


type alias PostStyle =
    { title : List Style
    , author : List Style
    , body : List Snippet
    }


style : Theme -> PostStyle
style theme =
    case theme of
        Dark ->
            darkPostStyle

        Light ->
            lightPostStyle


darkPostStyle : PostStyle
darkPostStyle =
    { title =
        []
    , author =
        []
    , body =
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

        -- Code block containers
        , Css.Global.pre
            [ backgroundColor <| Color.card Dark
            , color <| Color.secondaryFont Dark
            , borderRadius (px 20)
            , padding (px 20)
            ]
        ]
    }


lightPostStyle : PostStyle
lightPostStyle =
    { title =
        []
    , author =
        []
    , body =
        []
    }
