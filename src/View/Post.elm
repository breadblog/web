module View.Post exposing (view)


import Markdown
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events
import Message exposing (Msg)
import Model exposing (Post)


view : Post -> Html Msg
view post =
    div
        []
        [ h1
            [ class "title" ]
            [ text post.title ]
        , h2
            [ class "author" ]
            [ text post.author ]
        , markdown post.content
        ]


-- TODO: Change format to markdown : List (Attribute msg) -> List String -> Html msg
-- TODO: Apply styles to fromUnstyled unstyled somehow
markdown : String -> Html Msg
markdown content =
    let
        unstyled =
            Markdown.toHtml [] content

    in
        Html.Styled.fromUnstyled unstyled
