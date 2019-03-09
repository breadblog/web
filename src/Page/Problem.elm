module Page.Problem exposing (Model, view, toSession, init)


import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events
import Message exposing (Msg(..))
import Data.Session exposing (Session)
import Data.ProblemInfo exposing (ProblemInfo)


type alias Model =
    { session : Session
    , problemInfo : ProblemInfo
    , action : Maybe (Html Msg)
    }


init : Model -> Model
init model =
    model


toSession : Model -> Session
toSession model =
    model.session


view : Model -> Html Msg
view model =
    text "problem page"
