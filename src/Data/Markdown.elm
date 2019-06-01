module Data.Markdown exposing (Markdown, toHtml)

import Css.Global exposing (Snippet, descendants, global)
import Html.Attributes
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Markdown as MD


type Markdown =
    Markdown String


create : String -> Markdown
create str =
    Markdown str


toHtml : String -> List Snippet -> Markdown -> Html msg
toHtml className styles (Markdown content) =
    let
        markdown =
            MD.toHtml
                [ Html.Attributes.class (markdownClass className)
                ]
                content

        styledMarkdown =
            Html.Styled.fromUnstyled markdown
    in
    div
        [ class (className ++ "markdown-container") ]
        [ styledMarkdown
        , global
            [ Css.Global.class (markdownClass className)
                [ descendants styles ]
            ]
        ]


markdownClass : String -> String
markdownClass className =
    className ++ "-markdown"
