module Page.Donate exposing (Model, Msg, fromGeneral, init, toGeneral, update, view)

import Css exposing (..)
import Data.General as General exposing (General)
import Data.Route as Route exposing (Route(..))
import Data.Theme exposing (Theme)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (onClick)
import Message exposing (Compound)
import Update
import View.Page as Page exposing (PageUpdateOutput)



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
viewDonate _ _ =
    [ div
        [ id "donate-page"
        , css
            [ flex3 (int 1) (int 0) (int 0)
            , displayFlex
            , alignItems center
            , flexDirection column
            , overflowY auto
            , position relative
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
                [ sectionImg "/brave_lion.svg" ]
            ]
        , div
            [ class "patreon"
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
                [ sectionImg "/patreon.png" ]
            ]
        , div
            [ class "crypto"
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
                [ sectionImg "/ethereum.svg"
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


sectionImg : String -> Html msg
sectionImg imgSrc =
    img
        [ src imgSrc
        , css
            [ Css.height (px 150) ]
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
