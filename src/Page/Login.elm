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
import Message exposing (Compound(..), Msg(..))
import Style.Color as Color
import Update
import View.Page as Page exposing (PageUpdateOutput)



{- Model -}


type alias Model =
    Page.PageModel Internals


type alias Internals =
    { username : String
    , password : Password
    , error : Maybe String
    }


init : General -> Page.TransformModel Internals model -> Page.TransformMsg modMsg msg -> ( model, Cmd msg )
init =
    Page.init initInternals Cmd.none Login


initInternals : Internals
initInternals =
    { username = ""
    , password = Password.create ""
    , error = Nothing
    }


toGeneral : Model -> General
toGeneral =
    Page.toGeneral


fromGeneral : General -> Model -> Model
fromGeneral =
    Page.fromGeneral



{- Message -}


type alias Msg =
    Page.Msg ModMsg


type ModMsg
    = OnLogin (Result Http.Error Data.Login.Response)
    | TryLogin
    | UpdateUsername String
    | UpdatePassword Password
    | InputKeyUp Int



{- Update -}


update : Msg -> Model -> PageUpdateOutput ModMsg Internals
update =
    Page.update updateMod


updateMod : ModMsg -> General -> Internals -> Update.Output ModMsg Internals
updateMod msg general internals =
    case msg of
        OnLogin res ->
            case res of
                Err err ->
                    { model = { internals | error = Just "failed to login" }
                    , general = general
                    , cmd = Cmd.none
                    }

                Ok info ->
                    let
                        ( updated, cmd ) =
                            General.mapUser info.uuid general

                    in
                    { model = internals
                    , general = updated
                    , cmd = cmd
                    }

        TryLogin ->
            let
                cmd =
                    attemptLogin general internals.username internals.password
            in
            { model = internals
            , general = general
            , cmd = cmd
            }

        UpdateUsername username ->
            { model = { internals | username = username }
            , general = general
            , cmd = Cmd.none
            }

        UpdatePassword password ->
            { model = { internals | password = password }
            , general = general
            , cmd = Cmd.none
            }

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
            { model = internals
            , general = general
            , cmd = cmd
            }


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
