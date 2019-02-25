module View.Markdown exposing (toHtml)


import Markdown
import Html.Attributes
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Css.Global exposing (Snippet, descendants, global)


toHtml : String -> List Snippet -> String -> Html msg
toHtml className styles content =
    let
        markdown =
            Markdown.toHtml
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
