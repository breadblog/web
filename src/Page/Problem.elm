-- TODO: Scrap this page for different types of error pages
module Page.Problem exposing (Model, view, init)


import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events
import Message exposing (Msg(..))
import Data.Session exposing (Session)


type alias Model =
    {
    }


init : Model
init = 
    {}


view : Model -> Html Msg
view model =
    text "problem page"
