module Style.Post exposing (PostStyle, darkPostStyle, qnPostStyle)


import Css.Global exposing (Snippet)
import Css exposing (..)
import Style.Font exposing (firaCode)


type alias PostStyle =
    { title : List Style
    , author : List Style
    , content : List Snippet
    }


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
        ]
    }


qnPostStyle : PostStyle
qnPostStyle =
    { title =
        []
    , author =
        []
    , content =
        []
    }
