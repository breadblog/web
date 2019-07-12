module Page.Problems exposing (view)

import Css exposing (..)
import Data.General exposing (Msg)
import Data.Markdown as Markdown
import Data.Problem as Problem exposing (Description(..), Problem)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (onClick)
import Data.Theme as Theme exposing (Theme(..))
import Http exposing (Error(..))
import Json.Decode
import Style.Color as Color
import Style.Font as Font
import View.Svg as Svg
import Svg.Styled.Attributes as SvgAttr


view : List (Problem Msg) -> Html Msg
view problems =
    div
        [ css
            [ backgroundColor <| Color.slothBackground
            , Css.height <| pct 100
            , Css.width <| pct 100
            , displayFlex
            , flexDirection column
            , alignItems center
            ]
        ]
        [ img
            [ src "/sloth.svg"
            , css
                [ Css.height <| px 306
                , Css.width <| px 252
                ]
            ]
            []
        , div
            [ css
                [ color <| Color.primaryFont Dark
                , position relative
                , top <| px -50
                , fontFamilies Font.indieFlower
                , letterSpacing <| px 3
                , textAlign center
                ]
            ]
            [ h1 [] [ text "Sorry!" ]
            , h3 [] [ text "Looks like we ran into some issues:" ]
            ]
        , div
            [ class "problems"
            , css
                [ Css.width <| pct 100
                , displayFlex
                , flexDirection column
                , alignItems center
                ]
            ]
            <|
                List.map
                    (\p ->
                        let
                            title =
                                Problem.title p

                            description =
                                let
                                    contents =
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
                                                        [ text <| String.fromInt code ++ " HTTP Response" ]

                                                    BadBody body ->
                                                        [ text <| "Bad Body " ++ body ]
                                in
                                div [ class "description" ] contents

                            -- TODO: setup reaction
                        in
                        div
                            [ class "problem"
                            , css
                                [ Css.width <| pct 60
                                , backgroundColor <| Color.card Dark
                                , padding <| px 10
                                , borderRadius <| px 6
                                ]
                            ]
                            [ h1
                                [ class "title"
                                , css
                                    []
                                ]
                                [ text title
                                ]
                            , description
                            ]
                    )
                    problems
        , a
            [ rel "nofollow"
            , href "https://www.vecteezy.com"
            , css
                [ color <| Color.secondaryFont Dark
                , fontSize <| rem 1
                , position absolute
                , left <| px 0
                , bottom <| px 0
                , padding2 (px 5) (px 8)
                , borderRadius4 (px 0) (px 5) (px 0) (px 0)
                , textDecoration none
                , textAlign center
                , Css.height <| px 28
                , displayFlex
                , alignItems center
                , backgroundColor <| Color.primary Dark
                ]
            ]
            [ span [ css [ marginRight <| px 5 ] ] [ text "vector source" ]
            , Svg.link
                [ SvgAttr.height "16px"
                , SvgAttr.width "16px"
                ]
            ]
        ]


-- <a rel="nofollow" >Free Vector Design by: vecteezy.com</a>
