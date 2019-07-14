module Data.Markdown exposing (Markdown, create, decoder, encode, toHtml, toValue)

import Css exposing (Style)
import Css.Global exposing (Snippet, descendants, global)
import Html.Attributes
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Markdown as MD


type Markdown
    = Markdown String


create : String -> Markdown
create str =
    Markdown str


toHtml : String -> List Style -> List Snippet -> Markdown -> Html msg
toHtml className styles snippets (Markdown content) =
    let
        markdown =
            MD.toHtmlWith
                { githubFlavored = Just { tables = False, breaks = False }
                , defaultHighlighting = Nothing
                , sanitize = True
                , smartypants = False
                }
                [ Html.Attributes.class (markdownClass className)
                ]
                content

        styledMarkdown =
            Html.Styled.fromUnstyled markdown
    in
    div
        [ classList
            [ ( className, not <| String.isEmpty <| className )
            , ( "markdown-container", True )
            ]
        , css styles
        ]
        [ styledMarkdown
        , global
            [ Css.Global.class (markdownClass className)
                [ descendants snippets ]
            ]
        ]


markdownClass : String -> String
markdownClass className =
    className ++ "-markdown"


toValue : Markdown -> Attribute msg
toValue (Markdown md) =
    Html.Styled.Attributes.value md



{- JSON -}


decoder : Decoder Markdown
decoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                Decode.succeed (Markdown str)
            )


encode : Markdown -> Value
encode (Markdown str) =
    Encode.string str
