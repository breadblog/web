module Page.About exposing (Model, Msg, fromGeneral, init, toGeneral, update, view)

import Css exposing (..)
import Data.General as General exposing (General)
import Data.Route as Route exposing (Route(..))
import Data.Theme exposing (Theme)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href)
import Html.Styled.Events exposing (onClick)
import View.Footer as Footer
import View.Header as Header



{- Model -}


type Model
    = Model Internals


type alias Internals =
    { header : Header.Model
    , general : General
    }


toInternals : Model -> Internals
toInternals (Model internals) =
    internals


init : General -> ( Model, Cmd Msg )
init general =
    ( Model
        { header = Header.init
        , general = general
        }
    , Cmd.none
    )


toGeneral : Model -> General
toGeneral =
    toInternals >> .general


fromGeneral : General -> Model -> Model
fromGeneral general (Model internals) =
    Model { internals | general = general }



{- Message -}


type Msg
    = HeaderMsg Header.Msg



{- Update -}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        (Model internals) =
            model
    in
    case msg of
        HeaderMsg headerMsg ->
            let
                updatedHeader =
                    Header.update headerMsg internals.general internals.header
            in
            ( Model { internals | header = updatedHeader.model, general = updatedHeader.general }
            , Cmd.map HeaderMsg updatedHeader.cmd
            )



-- View --


view : Model -> List (Html Msg)
view (Model internals) =
    let
        general =
            internals.general

        theme =
            General.theme general

        version =
            General.version general
    in
    List.concat
        [ List.map (Html.Styled.map HeaderMsg) (Header.view internals.general internals.header)
        , viewAbout internals
        , Footer.view theme version
        ]


viewAbout : Internals -> List (Html Msg)
viewAbout _ =
    [ main_
        [ css
            [ flexGrow (num 1) ]
        ]
        []
    ]
