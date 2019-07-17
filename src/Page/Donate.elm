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


viewDonate : General -> Internals -> List (Html (Compound m))
viewDonate _ _ =
    [ div
        [ class "donate"
        , css
            [ flex3 (int 1) (int 0) (int 0)
            , displayFlex
            , flexDirection column
            , overflowY auto
            ]
        ]
        [ div
            [ class "brave"
            , css
                [ displayFlex
                , alignItems center
                , Css.height <| px 400
                , justifyContent spaceBetween
                ]
            ]
            [ div
                [ css
                    [ Css.width <| pct 35
                    , displayFlex
                    , justifyContent center
                    ]
                ]
                [ img
                    [ src "/brave_lion.svg"
                    , css
                        [ Css.height <| px 150 ]
                    ]
                    []
                ]
            ]
        , div
            [ class "patreon"
            , css
                [ displayFlex
                , alignItems center
                , Css.height <| px 400
                , justifyContent spaceBetween
                ]
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
                [ img
                    [ src "/patreon.png"
                    , css
                        [ Css.height <| px 150 ]
                    ]
                    []
                ]
            ]
        , div
            [ class "crypto" ]
            []
        ]
    ]
