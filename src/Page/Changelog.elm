module Page.Changelog exposing (view)

import Css exposing (..)
import Data.General as General exposing (General)
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



{- View -}


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
        [ List.map (Html.Styled.map HeaderMsg) (Header.view general internals.header)
        , viewChangelog internals
        , Footer.view theme version
        ]


viewChangelog : Internals -> List (Html Msg)
viewChangelog _ =
    [ main_
        [ css
            [ flexGrow <| num 1 ]
        ]
        []
    ]
