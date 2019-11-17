module Page.Home exposing (Model, Msg, init, mapGeneral, toGeneral, update, view)

import Css exposing (..)
import Data.General as General exposing (General)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import View.Footer as Footer
import View.Header as Header



-- TODO: shouldn't load home until it has either updated
-- resources, or loaded content from cache (depending on
-- network conditions)
{- Model -}


type Model
    = Model Internals


type alias Internals =
    { header : Header.Model
    , general : General
    }


init : General -> ( Model, Cmd Msg )
init general =
    ( Model
        { header = Header.init
        , general = general
        }
    , Cmd.map GeneralMsg (General.updateAll general)
    )


toGeneral : Model -> General
toGeneral =
    toInternals >> .general


mapGeneral : (General -> General) -> Model -> Model
mapGeneral transform (Model internals) =
    Model { internals | general = transform internals.general }


toInternals : Model -> Internals
toInternals (Model internals) =
    internals



{- Message -}


type Msg
    = HeaderMsg Header.Msg
    | GeneralMsg General.Msg



{- Update -}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model internals) =
    case msg of
        HeaderMsg headerMsg ->
            let
                updatedHeader =
                    Header.update headerMsg internals.general internals.header
            in
            ( Model { internals | header = updatedHeader.model, general = updatedHeader.general }
            , Cmd.map HeaderMsg updatedHeader.cmd
            )

        GeneralMsg generalMsg ->
            General.update generalMsg internals.general
                |> Tuple.mapFirst (\g -> Model { internals | general = g })
                |> Tuple.mapSecond (Cmd.map GeneralMsg)



{- View -}


view : Model -> List (Html Msg)
view (Model internals) =
    let
        general =
            internals.general
    in
    List.concat
        [ List.map (Html.Styled.map HeaderMsg) (Header.view internals.general internals.header)
        , viewHome internals
        , Footer.view (General.theme general) (General.version general)
        ]


viewHome : Internals -> List (Html Msg)
viewHome internals =
    [ main_
        [ css
            [ flexGrow (num 1) ]
        ]
        []
    ]
