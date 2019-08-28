module Page.Login exposing (Model, Msg, fromGeneral, init, toGeneral, update, view)

import Api
import Css exposing (..)
import Data.General as General exposing (General, Msg(..))
import Data.Login
import Data.Password as Password exposing (Password)
import Data.Route as Route exposing (Route(..))
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Html.Styled.Events as Events exposing (onClick, onInput)
import Http
import Json.Decode
import Style.Color as Color
import View.Page as Page



{- Model -}


type alias Model =
    Model Internals


type alias Internals =
    { username : String
    , password : Password
    , error : Maybe String
    , general : General
    }


init : General -> ( Model, Cmd Msg )
init general =
    Model
        { username = ""
        , password = Password.create ""
        , error = Nothing
        , general = general
        }


toGeneral : Model -> General
toGeneral (Model internals) =
    internals.general


fromGeneral : General -> Model -> Model
fromGeneral general (Model internals) =
    Model { internals | general = general }



{- Message -}


type Msg
    = OnLogin (Result Http.Error Data.Login.Response)
    | TryLogin
    | UpdateUsername String
    | UpdatePassword Password
    | InputKeyUp Int
    | GeneralMsg General.Msg



{- Update -}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        (Model internals) =
            model
    in
    case msg of
        OnLogin res ->
            case res of
                Err err ->
                    ( Model { internals | error = Just "failed to login" }
                    , Cmd.none
                    )

                Ok info ->
                    let
                        ( updatedGeneral, generalCmd ) =
                            General.mapUser info.uuid internals.general

                        cmd =
                            Cmd.map GeneralMsg generalCmd
                    in
                    ( Model { internals | general = updatedGeneral }
                    , cmd
                    )

        TryLogin ->
            ( model
            , attemptLogin general internals.username internals.password
            )

        UpdateUsername username ->
            ( Model { internals | username = username }
            , Cmd.none
            )

        UpdatePassword password ->
            ( Model { internals | password = password }
            , Cmd.none
            )

        InputKeyUp code ->
            let
                cmd =
                    case code of
                        -- enter
                        13 ->
                            attemptLogin general internals.username internals.password

                        _ ->
                            Cmd.none
            in
            ( model
            , cmd
            )


attemptLogin : General -> String -> Password -> Cmd (Compound ModMsg)
attemptLogin general username password =
    let
        mode =
            General.mode general

        msg =
            \r ->
                r
                    |> OnLogin
                    |> Mod
    in
    Api.post
        { expect = Http.expectJson msg <| Data.Login.decodeResponse
        , body =
            Http.jsonBody <|
                Data.Login.encodeRequest <|
                    Data.Login.Request username password
        , url = Api.url mode "/login/"
        }



{- View -}


view : Model -> Page.ViewResult ModMsg
view model =
    Page.view model viewLogin


viewLogin : General -> Internals -> List (Html (Compound ModMsg))
viewLogin general internals =
    let
        theme =
            General.theme general
    in
    [ div
        [ class "login"
        , css
            [ flexGrow <| num 1
            , displayFlex
            , flexDirection column
            , alignItems center
            , justifyContent center
            ]
        ]
        [ div
            [ css
                [ displayFlex
                , flexDirection column
                , padding <| px 40
                , backgroundColor <| Color.card theme
                ]
            ]
            [ h1
                [ css
                    [ marginTop <| px 0
                    ]
                ]
                [ text "Login" ]
            , input
                [ type_ "text"
                , onInput (\u -> Mod <| UpdateUsername u)
                , onKeyUp (\i -> Mod <| InputKeyUp i)
                ]
                []
            , input
                [ type_ "password"
                , onInput (\p -> Mod <| UpdatePassword <| Password.create p)
                , onKeyUp (\i -> Mod <| InputKeyUp i)
                ]
                []
            , div
                [ class "buttons"
                , css
                    [ displayFlex
                    , flexDirection row
                    , justifyContent spaceBetween
                    ]
                ]
                [ button
                    [ onClick <| Global <| GeneralMsg <| TryLogout
                    ]
                    [ text "logout" ]
                , button
                    [ onClick <| Mod TryLogin
                    ]
                    [ text "submit" ]
                ]
            ]
        ]
    ]


onKeyUp : (Int -> Compound ModMsg) -> Attribute (Compound ModMsg)
onKeyUp tagger =
    Events.on "keyup" <| Json.Decode.map tagger Events.keyCode
