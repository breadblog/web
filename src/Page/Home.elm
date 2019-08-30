module Page.Home exposing (Model, init, toGeneral, update, view)

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
toGeneral =
    toInternals >> .general


toInternals : Model -> Internals
toInternals (Model internals) =
    internals



{- Message -}


type Msg
    = HeaderMsg Header.Msg



{- Update -}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model internals) =
    case msg of
        HeaderMsg headerMsg ->
            Header.update headerMsg internals.general internals.header
                -- TODO: this returns a record now
                |> Tuple.mapFirst (\h -> Model { internals | header = h })
                |> Tuple.mapSecond (Cmd.map HeaderMsg)



{- View -}


view : Model -> List (Html Msg)
view (Model internals) =
    []
