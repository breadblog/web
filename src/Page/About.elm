module Page.About exposing (Model, Msg, fromContext, init, toContext, update, view)

import Css exposing (..)
import Data.Context as Context exposing (Context)
import Data.Route as Route exposing (Route(..))
import Data.Theme exposing (Theme)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href)
import Html.Styled.Events exposing (onClick)
import Page



-- Model --


type alias Model =
    { context : Context }


init : Context -> ( Model, Cmd Msg )
init context =
    ( Model context, Cmd.none )


toContext : Model -> Context
toContext =
    Page.toContext


fromContext : Context -> Model -> Model
fromContext =
    Page.fromContext



-- Message --


type Msg
    = NoOp



-- Update --


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



-- View --


view : Model -> List (Html Msg)
view _ =
    []
