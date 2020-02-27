module Page.About exposing (Model, Msg, fromContext, init, toContext, update, view)

import Css exposing (..)
import Data.Context as Context exposing (Context)
import Data.Route as Route exposing (Route(..))
import Data.Theme exposing (Theme)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href)
import Html.Styled.Events exposing (onClick)
import Message exposing (Compound)
import Update
import View.Page as Page exposing (PageUpdateOutput)



-- Model --


type alias Model =
    Page.PageModel Internals


type alias Internals =
    {}


init : Context -> Page.TransformModel Internals model -> Page.TransformMsg modMsg msg -> ( model, Cmd msg )
init =
    Page.init {} Cmd.none About


toContext : Model -> Context
toContext =
    Page.toContext


fromContext : Context -> Model -> Model
fromContext =
    Page.fromContext



-- Message --


type alias Msg =
    Page.Msg ModMsg


type ModMsg
    = NoOp



-- Update --


update : Msg -> Model -> PageUpdateOutput ModMsg Internals
update =
    Page.update updateMod


updateMod : msg -> Context -> Internals -> Update.Output ModMsg Internals
updateMod _ general internals =
    { model = internals
    , general = general
    , cmd = Cmd.none
    }



-- View --


view : Model -> Page.ViewResult msg
view model =
    Page.view model viewAbout


viewAbout : Context -> Internals -> List (Html (Compound m))
viewAbout _ _ =
    []
