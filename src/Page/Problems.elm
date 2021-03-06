module Page.Problems exposing (view)

import Css exposing (..)
import Data.Context exposing (Msg(..))
import Data.Markdown as Markdown
import Data.Problem as Problem exposing (Description(..), Problem)
import Data.Theme exposing (Theme(..))
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (onClick)
import Http exposing (Error(..))
import Json.Decode
import Style.Button
import Style.Color as Color
import Style.Font as Font
import Style.Screen as Screen exposing (Screen(..))
import Style.Shadow as Shadow
import Svg.Styled.Attributes as SvgAttr
import View.Svg as Svg


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
            , overflowY auto
            ]
        ]
        [ img
            [ src "/sloth.svg"
            , css
                [ Css.height <| px 306
                , Css.width <| px 252
                , flexShrink (int 0)
                , Screen.style Screen.mobile
                    [ Css.height (px 228)
                    , Css.width (px 189)
                    ]
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
                , Css.width (pct 92)
                , Screen.style Screen.mobile
                    [ top (px -50) ]
                ]
            ]
            [ h1 [] [ text "Sorry!" ]
            , h3 [] [ text "Looks like we ran into some issues:" ]
            ]
        , div
            [ class "problems"
            , css
                [ Css.width <| pct 100
                , position relative
                , displayFlex
                , flexDirection column
                , alignItems center
                , marginBottom (px 0)
                , Screen.style Screen.mobile
                    [ top (px -50) ]
                ]
            ]
          <|
            List.indexedMap
                (\i p ->
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
                                            [ Markdown.toHtml "problem" [] [] err ]

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
                            div
                                [ class "description"
                                , css
                                    [ Css.width (pct 90)
                                    ]
                                ]
                                contents
                    in
                    div
                        [ class "problem"
                        , css
                            [ Css.width <| pct 30
                            , backgroundColor <| Color.card Dark
                            , padding <| px 10
                            , borderRadius <| px 6
                            , displayFlex
                            , flexDirection column
                            , alignItems center
                            , Shadow.dp6
                            , Screen.style Screen.mobile
                                [ Css.width (pct 80) ]
                            ]
                        ]
                        [ h1
                            [ class "title"
                            , css
                                [ margin <| px 8
                                , fontSize (rem 1.4)
                                ]
                            ]
                            [ text title
                            ]
                        , div
                            [ css
                                [ Css.width <| pct 90
                                , Css.height <| px 1
                                , backgroundColor <| Color.tertiaryFont Dark
                                ]
                            ]
                            []
                        , description
                        , div
                            [ class "buttons"
                            , css
                                [ margin2 (px 5) (px 0) ]
                            ]
                            [ button
                                [ onClick <| ReportErr p
                                , css
                                    [ buttonStyle
                                    , backgroundColor <| Color.primary Dark
                                    ]
                                ]
                                [ text "Report" ]
                            , case Problem.handler p of
                                Just handler ->
                                    button
                                        [ onClick <| WithDismiss i <| Problem.handlerMsg handler
                                        , css
                                            [ buttonStyle
                                            , Style.Button.submit
                                            ]
                                        ]
                                        [ Problem.handlerText handler ]

                                Nothing ->
                                    button
                                        [ onClick <| DismissProblem i
                                        , css
                                            [ buttonStyle
                                            , Style.Button.submit
                                            ]
                                        ]
                                        [ text "Dismiss" ]
                            ]
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


buttonStyle : Style
buttonStyle =
    Css.batch
        [ margin2 (px 0) (px 20)
        , Style.Button.default
        ]
