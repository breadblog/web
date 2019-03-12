module Page.Problem.CorruptCache exposing (Model, init, view)


import Html.Styled exposing (..)
import Json.Decode exposing (Error(..))


type alias Model =
    { error : Error
    }


init : Error -> Model
init error =
    { error = error }


view : Model -> Html msg
view model =
    text "problem page"
