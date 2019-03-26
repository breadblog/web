module Page.Profile exposing (Model, Msg(..), fromGeneral, init, toGeneral, update, view)

import Css exposing (..)
import Data.Cache as Cache exposing (Cache)
import Data.General as General exposing (General)
import Data.Route as Route exposing (Route(..))
import Data.Session as Session exposing (Session)
import Data.Theme exposing (Theme)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href)
import Html.Styled.Events exposing (onClick)
import Message exposing (Compound(..), Msg(..))



-- Model


type alias Model =
    { cache : Cache
    , session : Session
    }


init : (Model -> e) -> General -> ( e, Cmd msg )
init transform general =
    ( transform <|
        { session = General.session general
        , cache = General.cache general
        }
    , Cmd.none
    )


fromGeneral : General -> Model -> Model
fromGeneral general model =
    { model | cache = General.cache general, session = General.session general }


toGeneral : Model -> General
toGeneral model =
    General.init model.session model.cache



-- Message


type Msg
    = NoOp



-- Update --


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- View


view : Model -> Html (Compound Msg)
view model =
    let
        theme =
            Cache.theme model.cache
    in
    div
        [ class (Route.toClass Profile) ]
        []
