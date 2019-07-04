module Page.Problems exposing (view)

import Html.Styled exposing (..)
import Css exposing (..)
import Data.General exposing (Msg)
import Data.Problem as Problem exposing (Problem, Description(..))
import Data.Markdown as Markdown
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (onClick)
import Json.Decode
import Http exposing (Error(..))


view : List (Problem Msg) -> Html Msg
view problems =
    div
        [ class "problems" ]
        <| List.map
            (\p -> 
                let
                    title =
                        div [ class "title" ] [ text <| Problem.title p ]

                    description =
                        let contents =
                                case Problem.description p of
                                    JsonError err ->
                                        [ text <| Json.Decode.errorToString err ]

                                    MarkdownError err ->
                                        [ Markdown.toHtml "problem" [] err ]

                                    HttpError err ->
                                        case err of
                                            BadUrl url ->
                                                [ text <| "Bad URL: " ++ url ]

                                            Timeout ->
                                                [ text "HTTP request timed out" ]

                                            NetworkError ->
                                                [ text "No internet" ]

                                            BadStatus code ->
                                                [ text <| (String.fromInt code) ++ " HTTP Response" ]

                                            BadBody body ->
                                                [ text <| "Bad Body " ++ body ]


                        in
                        div [ class "description" ] contents


                    -- TODO: setup reaction

                in
                div
                    [ class "problem" ]
                    [ title
                    , description
                    ]
            )
            problems
