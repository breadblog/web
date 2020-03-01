module Page.Home exposing (Model, Msg, fromContext, init, toContext, update, view)

import Css exposing (..)
import Data.Context as Context exposing (Context)
import Data.Post as Post exposing (Core, Post, Preview)
import Data.Route as Route exposing (Route(..))
import Data.Theme exposing (Theme)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href)
import Html.Styled.Events exposing (onClick)
import Page


-- Model


type alias Model =
    { context : Context
    , posts : List (Post Core Preview)
    }



init : Context -> ( Model, Cmd Msg )
init context =
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
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



-- View --


view : Model -> List (Html Msg)
view model =
    [ main_
        [ css
            [ flexGrow <| num 1
            ]
        ]
        []
    ]
