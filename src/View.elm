module View exposing (view)

import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes exposing (..)
import Message exposing (Msg)
import Model exposing (Model)
import Url


view : Model -> Document Msg
view model =
    { title = "Bits n' Bites"
    , body =
        [ text "The current URL is: "
        , b [] [ text (Url.toString model.url) ]
        , ul []
            [ viewLink "/home"
            , viewLink "/profile"
            , viewLink "/reviews/the-century-of-the-self"
            , viewLink "/reviews/public-opinion"
            , viewLink "/reviews/shah-of-shahs"
            ]
        ]
    }


viewLink : String -> Html msg
viewLink path =
    li [] [ a [ href path ] [ text path ] ]
