module Page.Home exposing (Model, Msg(..), init, update, view)

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
    {}


init : (Page.Model Model -> e) -> General -> ( e, Cmd msg )
init transform general =
    ( transform
        (Page.init {} Cmd.none Home general)
    , Cmd.none
    )


-- Message --


type Msg
    = NoOp



-- Update --


update : Page.Msg Msg -> Page.Model Model -> ( Page.Model Model, Cmd (Page.Msg Msg))
update =
    Page.update updatePage


updatePage : Msg -> Page.Model Model -> ( Model, Cmd Msg )
updatePage msg pageModel =
    let model =
            Page.mod pageModel

    in
    case msg of
        NoOp ->
            ( model, Cmd.none )


-- View --


view : Page.Model Model -> Html (Compound Msg)
view model =
    Page.view model
        (\theme cache modModel ->
            homeMain
        )


homeMain : List (Html (Compound Msg))
homeMain =
    [ main_
        [ css
            [ flexGrow <| num 1
            ]
        ]
        []
    ]
