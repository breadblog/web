module Style.Post exposing (PostStyle, style)

import Css exposing (..)
import Css.Global exposing (Snippet)
import Style.Font exposing (firaCode)
import Data.Theme exposing (Theme(..))


type alias PostStyle =
    { title : List Style
    , author : List Style
    , content : List Snippet
    }


style : Theme -> PostStyle
style theme =
    case theme of
        Dark -> darkPostStyle

        Light -> lightPostStyle


darkPostStyle : PostStyle
darkPostStyle =
    { title =
        []
    , author =
        []
    , content =
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
            [ backgroundColor (hex "282828")
            , color (hex "ebdbb2")
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
    , content =
        []
    }
