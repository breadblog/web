module Page.Donate exposing (Model, init, toGeneral, update, view)

import Css exposing (..)
import Data.General as General exposing (General)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import View.Header as Header



{- Model -}


type Model
    = Model Internals


type alias Internals =
    { header : Header.Model
    , general : General
    }


init : General -> Model
init general =
    Model
        { header = Header.init
        , general = general
        }


toGeneral : Model -> General
toGeneral (Model model) =
    model.general



{- Msg -}


type Msg
    = HeaderMsg Header.Msg



{- Update -}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



{- View -}


view : Model -> List (Html Msg)
view (Model internals) =
    [ main_
        [ css
            [ flexGrow (num 1) ]
        ]
        []
    ]
