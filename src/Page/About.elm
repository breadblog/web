module Page.About exposing (Model, Msg, fromGeneral, init, toGeneral, update, view)

import Css exposing (..)
import Data.General as General exposing (General)
import Data.Route as Route exposing (Route(..))
import Data.Theme exposing (Theme)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href)
import Html.Styled.Events exposing (onClick)
import Message exposing (Compound)
import View.Page as Page



-- Model --


type alias Model =
    Page.PageModel Internals


type alias Internals =
    {}


init : General -> Page.TransformModel Internals model -> Page.TransformMsg modMsg msg -> ( model, Cmd msg )
init =
    Page.init {} Cmd.none About


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


update : Msg -> Model -> ( Model, Cmd Msg )
update =
    Page.update updateMod


updateMod : msg -> s -> c -> Internals -> ( Internals, Cmd msg )
updateMod _ _ _ internals =
    ( internals, Cmd.none )



-- View --


view : Model -> Page.ViewResult msg
view model =
    Page.view model viewAbout


viewAbout : Session -> Cache -> Internals -> List (Html (Compound m))
viewAbout _ _ _ =
    []
