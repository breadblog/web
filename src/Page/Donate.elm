module Page.Donate exposing (Model, Msg, fromGeneral, init, toGeneral, update, view)

import Css exposing (..)
import Data.General as General exposing (General)
import Data.Markdown as Markdown exposing (Markdown)
import Data.Route as Route exposing (Route(..))
import Data.Theme exposing (Theme)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (onClick)
import Message exposing (Compound)
import Style.Card as Card
import Style.Color as Color
import Svg.Styled.Attributes as SvgAttr
import Update
import View.Page as Page exposing (PageUpdateOutput)
import View.Svg as Svg



-- Model --


type alias Model =
    Page.PageModel Internals


type alias Internals =
    {}


init : General -> Page.TransformModel Internals model -> Page.TransformMsg modMsg msg -> ( model, Cmd msg )
init =
    Page.init {} Cmd.none Donate


toGeneral : Model -> General
toGeneral =
    Page.toGeneral


fromGeneral : General -> Model -> Model
fromGeneral =
    Page.fromGeneral



-- Message --


type alias Msg =
    Page.Msg ModMsg


type ModMsg
    = NoOp



-- Update --


update : Msg -> Model -> PageUpdateOutput ModMsg Internals
update =
    Page.update updateMod


updateMod : msg -> General -> Internals -> Update.Output ModMsg Internals
updateMod _ general internals =
    { model = internals
    , general = general
    , cmd = Cmd.none
    }



-- View --


view : Model -> Page.ViewResult msg
view model =
    Page.view model viewDonate



{-
   TODO: animations?
-}


viewDonate : General -> Internals -> List (Html (Compound m))
viewDonate general _ =
    let
        theme =
            General.theme general
    in
    [ div
        [ id "donate-page"
        , css
            [ flex3 (int 1) (int 0) (int 0)
            , displayFlex
            , alignItems center
            , flexDirection column
            , overflowY auto
            , position relative
            , overflowX Css.hidden
            ]
        ]
        [ div
            [ class "summary"
            , css
                [ Css.width (pct 50)
                , flex3 (int 0) (int 0) (px 300)
                , displayFlex
                , flexDirection column
                , alignItems center
                , marginTop (px 30)
                ]
            ]
            [ h1
                []
                [ text "Considering Donating?" ]
            , p
                [ css
                    [ fontSize (rem 1.2) ]
                ]
                [ text "Before you do, we just wanted to clarify that our content does not depend on donations from our readers. We are fortunate enough to use some great services that support open source, which allows our hosting fees to be negligible. If you still want to donate and support us, know that we greatly appreciate it!"
                ]
            ]
        , div
            [ class "brave"
            , id "donate-brave-section"
            , css
                [ sectionStyle ]
            ]
            [ div
                [ css
                    [ Css.width <| pct 35
                    , displayFlex
                    , justifyContent center
                    ]
                ]
                [ sectionImg "/brave_lion.svg" Left
                ]
            , sectionDescription
                theme
                (Just "https://brave.com")
                "Brave Browser"
                (Markdown.create "Brave is an open source browser attempting to give control of the web back to you, the users. It has a built in ad/tracker blocking, so you don't have to worry about creepy companies following you across the web. And if you choose to, you can get paid to see ads integrated into your browser, which helps to maintain your privacy and security while also allowing you to get paid for your attention. And if you choose to give back some of that back to content creators such as us, it's easy to contribute. You can find out more [here](https://brave.com)")
                Right
            , filler
            ]
        , div
            [ class "patreon"
            , id "donate-patreon-section"
            , css
                [ sectionStyle ]
            ]
            [ div
                [ css
                    [ flex3 (int 1) (int 0) (int 0) ]
                ]
                []
            , div
                [ css
                    [ Css.width <| pct 35
                    , displayFlex
                    , justifyContent center
                    ]
                ]
                [ sectionImg "/patreon.png" Right
                ]
            ]
        , div
            [ class "crypto"
            , id "donate-crypto-section"
            , css
                [ sectionStyle ]
            ]
            [ div
                [ css
                    [ Css.width <| pct 35
                    , displayFlex
                    , justifyContent center
                    ]
                ]
                [ sectionImg "/ethereum.svg" Left
                ]
            ]
        ]
    , div
        [ class "overlay"
        , css
            [ position absolute
            , Css.height (pct 30)

            -- TODO: add a gradient opacity background
            ]
        ]
        []
    ]


type Side
    = Left
    | Right


sectionImg : String -> Side -> Html msg
sectionImg imgSrc side =
    img
        [ src imgSrc
        , classList
            [ ( "right", side == Right )
            , ( "left", side == Left )
            , ( "animated", True )
            , ( "hidden", True )
            ]
        , css
            [ Css.height (px 150) ]
        ]
        []


sectionDescription : Theme -> Maybe String -> String -> Markdown -> Side -> Html msg
sectionDescription theme maybeUrl title description side =
    div
        [ classList
            [ ( "right", side == Right )
            , ( "left", side == Left )
            , ( "animated", True )
            , ( "hidden", True )
            , ( "content", True )
            , ( "delay-1s", True )
            ]
        , css
            [ displayFlex
            , flexDirection column
            , flex3 (int 2) (int 0) (pct 35)
            , Card.style theme
            ]
        ]
        [ div
            [ css
                [ Card.headingStyle theme
                , flexBasis auto
                , justifyContent spaceBetween
                ]
            ]
            [ h1
                [ class "title"
                , css
                    [ fontSize (rem 1.2)
                    , fontWeight (int 500)
                    , margin4 (px 5) (px 0) (px 5) (px 20)
                    ]
                ]
                [ text title ]
            , case maybeUrl of
                Just url ->
                    a
                        [ href url
                        , css
                            [ color (Color.secondaryFont theme)
                            , marginRight (px 10)
                            , displayFlex
                            , alignItems center
                            , textDecoration none
                            ]
                        ]
                        [ Svg.link
                            [ SvgAttr.css
                                [ Css.width (px 16)
                                , Css.height (px 16)
                                , marginLeft (px 5)
                                , position relative
                                , top (px -1)
                                ]
                            ]
                        ]

                Nothing ->
                    text ""
            ]
        , div
            [ class "description"
            , css
                [ fontSize (rem 1.0)
                , padding (px 15)
                , letterSpacing (px 0.5)
                ]
            ]
            [ Markdown.toHtml "donate-desc" [] [] description ]
        ]


filler : Html msg
filler =
    div
        [ css
            [ flex3 (int 1) (int 0) (px 0) ]
        ]
        []



{- Styles -}


sectionStyle : Style
sectionStyle =
    Css.batch
        [ displayFlex
        , alignItems center
        , justifyContent spaceBetween
        , flexBasis auto
        , flex3 (int 0) (int 0) (px 300)
        , marginBottom (px 50)
        , Css.width (pct 100)
        ]
