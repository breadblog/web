module Data.Markdown exposing (Markdown, create, decoder, encode, toHtml)

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
