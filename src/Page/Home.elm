module Page.Home exposing (Model, Msg(..), fromGeneral, init, toGeneral, view, update)

import Css exposing (..)
import Data.Cache as Cache exposing (Cache)
import Data.Route as Route exposing (Route(..))
import Data.Session as Session exposing (Session)
import Data.Theme exposing (Theme)
import Data.General as General exposing (General)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href)
import Html.Styled.Events exposing (onClick)
import Message exposing (Compound(..))
import View.Header as Header



-- Model


type alias Model =
    { cache : Cache
    , session : Session
    , header : Header.Model
    }


init : (Model -> e) -> General -> ( e, Cmd msg )
init transform general =
    ( transform <|
        { session = General.session general
        , cache = General.cache general
        , header = Header.init
        }
    , Cmd.none
    )


fromGeneral : General -> Model -> Model
fromGeneral general model =
    { model | cache = General.cache general, session = General.session general }


toGeneral : Model -> General
toGeneral model =
    General.init model.session model.cache



-- Message --


type Msg
    = HeaderMsg Header.Msg


-- Update --


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        HeaderMsg headerMsg ->
            let
                ( headerModel, headerCmd ) =
                    Header.update headerMsg model.header

                cmd =
                    Cmd.map HeaderMsg headerCmd

            in
                ( { model | header = headerModel }, cmd )



-- View --


view : Model -> Html (Compound Msg)
view model =
    let
        theme =
            Cache.theme model.cache

        tags =
            Cache.tags model.cache

        authors =
            Cache.authors model.cache

        header =
            Html.Styled.map
                (Message.map HeaderMsg)
                (Header.view theme authors tags model.header)
                
    in
    div
        [ class (Route.toClass Home) ]
        [ header
        ]
