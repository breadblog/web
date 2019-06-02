module Page.Home exposing (Model, Msg, fromGeneral, init, toGeneral, update, view)

import Css exposing (..)
import Data.General as General exposing (General)
import Data.Post as Post exposing (Post, Preview)
import Data.Route as Route exposing (Route(..))
import Data.Theme exposing (Theme)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href)
import Html.Styled.Events exposing (onClick)
import Message exposing (Compound(..))
import Style.Color as Color
import View.Footer as Footer
import View.Header as Header
import View.Page as Page



{--

    Home Page
    =========

    Present
    -------

    Simple homescreen that simply shows cards for the various posts
    in chronological order

    Future
    ------

    Intention of the home page is to allow discovery of blog posts
    that may be of interest to the user. We do this through a
    Netflix styled interface that shows various categories and/or
    authors to the user depending on what the web client
    belieaves they would be most interested in. Similar to Netflix,
    it allows for duplicates to occur between rows. Unlike Netflix
    however, we allow the user to customize the content they will
    see (by authors or tags).

--}
-- Model


type alias Model =
    Page.PageModel Internals


type alias Internals =
    { posts : List (Post Preview) }


type alias Row =
    { posts : List (Post Preview)
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
viewHome _ cache internals =
    let
        new =
            { posts = internals.posts
            }

        theme =
            Cache.theme cache
    in
    [ main_
        [ css
            [ flexGrow <| num 1
            ]
        ]
        []
    ]
