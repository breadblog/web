module Page.Home exposing (Model, Msg(..), view, init)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href)
import Html.Styled.Events exposing (onClick)
import Data.Theme exposing (Theme)
import Data.Route as Route exposing (Route(..))
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
