module Page.Home exposing (Model, Msg, fromContext, init, toContext, update, view)

import Css exposing (..)
import Data.Context as Context exposing (Context)
import Data.Post as Post exposing (Core, Post, Preview)
import Data.Route as Route exposing (Route(..))
import Data.Theme exposing (Theme)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href)
import Html.Styled.Events exposing (onClick)
import Message exposing (Compound(..))
import Style.Color as Color
import View.Footer as Footer
import View.Header as Header
import Page


-- Model


type alias Model =
    { context : Context
    , posts : List (Post Core Preview)
    }



init : Context -> Model
init =
    ( { posts = []
      , context = context
      }
    , Cmd.none
    )


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
update msg general internals =
    case msg of
        NoOp ->
            ( model, Cmd.none )



-- View --


view : Model -> Page.ViewResult ModMsg
view model =
    Page.view model viewHome


viewHome : Model -> List (Html Msg)
viewHome general internals =
    [ main_
        [ css
            [ flexGrow <| num 1
            ]
        ]
        []
    ]
