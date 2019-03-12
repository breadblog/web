-- TODO: Scrap this page for different types of error pages


module Page.Problem.CorruptCache exposing (Model, init, view)

import Html.Styled exposing (..)


type alias Model =
    { message : String
    }


init : String -> Model
init message =
    { message = message }


view : Model -> Html msg
view model =
    text "problem page"
