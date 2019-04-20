module Page.Home exposing (Model, Msg, init, update, view, toGeneral, fromGeneral)

import Css exposing (..)
import Data.Cache as Cache exposing (Cache)
import Data.General as General exposing (General)
import Data.Route as Route exposing (Route(..))
import Data.Session as Session exposing (Session)
import Data.Theme exposing (Theme)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href)
import Html.Styled.Events exposing (onClick)
import Message exposing (Compound(..))
import View.Footer as Footer
import View.Header as Header
import View.Page as Page



-- Model


type alias Model =
    Page.PageModel Internals


type alias Internals =
    {}


init : General -> Page.TransformModel Internals mainModel -> Page.TransformMsg ModMsg mainMsg -> (mainModel, Cmd mainMsg)
init =
    Page.init {} Cmd.none Home


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


updateMod : ModMsg -> s -> c -> Internals -> ( Internals, Cmd ModMsg )
updateMod msg _ _ internals =
    case msg of
        NoOp ->
            ( internals, Cmd.none )



-- View --


view : Model -> Page.ViewResult ModMsg
view model =
    Page.view model viewHome


viewHome : Session -> Cache -> Internals -> List (Html (Compound ModMsg))
viewHome _ _ _ =
    [ main_
        [ css
            [ flexGrow <| num 1
            ]
        ]
        []
    ]
