module Page.Home exposing (Model, Msg(..), init, view)

import Css exposing (..)
import Data.Route as Route exposing (Route(..))
import Data.Theme exposing (Theme)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href)
import Html.Styled.Events exposing (onClick)
import Message
import View.Header



-- Model


type alias Model =
    { theme : Theme
    }


init : (Model -> e) -> Theme -> ( e, Cmd msg )
init transform theme =
    ( transform <|
        { theme = theme
        }
    , Cmd.none
    )



-- Message


type Msg
    = Global Message.Msg



-- View


view : Model -> Html Message.Msg
view model =
    div
        [ class (Route.toClass Home) ]
        [ View.Header.view model.theme
        ]
