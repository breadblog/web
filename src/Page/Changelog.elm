module Page.Changelog exposing (Model, Msg, fromGeneral, init, toGeneral, update, view)

import Css exposing (..)
import Data.General as General exposing (General)
import Data.Route as Route exposing (Route(..))
import Data.Theme exposing (Theme)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href)
import Html.Styled.Events exposing (onClick)
import Message exposing (Compound)
import Update
import View.Page as Page exposing (PageUpdateOutput)



{-
   Changelog page
-}
-- Model --


type alias Model =
    Page.PageModel Internals


type alias Internals =
    {}


init : General -> Page.TransformModel Internals model -> Page.TransformMsg modMsg msg -> ( model, Cmd msg )
init =
    Page.init {} Cmd.none Changelog


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
    Page.view model viewChangelog


viewChangelog : General -> Internals -> List (Html (Compound m))
viewChangelog _ _ =
    [ main_
        [ css
            [ flexGrow <| num 1 ]
        ]
        []
    ]
