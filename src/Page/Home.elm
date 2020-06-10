module Page.Home exposing (Model, Msg, fromContext, fromContextMsg, init, toContext, update, view)

import Css exposing (..)
import Data.Author as Author exposing (Author)
import Data.Context as Context exposing (Context)
import Data.Post as Post exposing (Core, Post, Preview)
import Data.Route as Route exposing (Route(..))
import Data.Theme exposing (Theme)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href)
import Html.Styled.Events exposing (onClick)
import Page
import Http



-- Model


type alias Model =
    { context : Context
    , posts : List (Post Core Preview)
    , authors : List Author
    }


init : Context -> ( Model, Cmd Msg )
init context =
    ( { context = context
      , posts = []
      , authors = []
      }
    , Cmd.none
    )


toContext : Model -> Context
toContext =
    Page.toContext


fromContext : Context -> Model -> Model
fromContext =
    Page.fromContext


fromContextMsg : Context.Msg -> Msg
fromContextMsg msg =
    Ctx msg



-- Message --


type Msg
    = Ctx Context.Msg
    | Fetch Http.Error (List (Post Core Preview), List Author)



-- Update --


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ context } as model) =
    case msg of
        Ctx contextMsg ->
            let
                ( updatedContext, cmd ) =
                    Context.update contextMsg context
            in
            ( { model | context = updatedContext }, Cmd.map Ctx cmd )

        Fetch ->
            Debug.todo "here"



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
