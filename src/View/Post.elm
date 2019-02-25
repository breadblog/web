module View.Post exposing (view)


import View.Markdown as Markdown
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events
import Css exposing (Style)
import Css.Global exposing (Snippet)
import Message exposing (Msg)
import Model exposing (Post)
import Style.Post exposing (PostStyle)


view : String -> Post -> PostStyle -> Html Msg
view name post postStyle =
    div
        [ class name ]
        [ h1
            [ class "title" ]
            [ text post.title ]
        , h2
            [ class "author" ]
            [ text post.author ]
        , Markdown.toHtml name postStyle.content post.content
        ]