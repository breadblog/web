module Page.Home exposing (Model, Msg, fromGeneral, init, toGeneral, update, view)

import Css exposing (..)
import Data.General as General exposing (General)
import Data.Post as Post exposing (Core, Post, Preview)
import Data.Route as Route exposing (Route(..))
import Data.Theme exposing (Theme)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href)
import Html.Styled.Events exposing (onClick)
import Style.Color as Color
import View.Footer as Footer
import View.Header as Header



-- Model


type alias Model =
    Page.PageModel Internals


type alias Internals =
    { posts : List (Post Core Preview) }


type alias Row =
    { posts : List (Post Core Preview)
    }


init : General -> Page.TransformModel Internals mainModel -> Page.TransformMsg ModMsg mainMsg -> ( mainModel, Cmd mainMsg )
init =
    Page.init
        { posts = [] }
        Cmd.none
        Home


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


updateMod : ModMsg -> General -> Internals -> Update.Output ModMsg Internals
updateMod msg general internals =
    case msg of
        NoOp ->
            { model = internals
            , cmd = Cmd.none
            , general = general
            }



-- View --


view : Model -> Page.ViewResult ModMsg
view model =
    Page.view model viewHome


viewHome : General -> Internals -> List (Html (Compound ModMsg))
viewHome general internals =
    let
        new =
            { posts = internals.posts
            }

        theme =
            General.theme general
    in
    [ main_
        [ css
            [ flexGrow <| num 1
            ]
        ]
        []
    ]
