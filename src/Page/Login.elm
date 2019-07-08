module Page.Login exposing (Model, Msg, fromGeneral, init, toGeneral, update, view)

import Api
import Css exposing (..)
import Data.General as General exposing (General)
import Data.Login
import Data.Password as Password exposing (Password)
import Data.Route as Route exposing (Route(..))
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Html.Styled.Events as Events exposing (onClick, onInput)
import Http
import Message exposing (Compound(..))
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
    = OnLogin (Result Http.Error ())
    | TryLogin
    | UpdateUsername String
    | UpdatePassword Password



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

                Ok _ ->
                    { model = internals
                    , general = general
                    , cmd = Cmd.none
                    }

        TryLogin ->
            let
                mode =
                    General.mode general

                cmd =
                    Api.post
                        { expect = Http.expectWhatever <| \r -> Mod (OnLogin r)
                        , body = Data.Login.encode <| Data.Login.Request internals.username internals.password
                        , url = Api.url mode "/login/"
                        }
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
                ]
                []
            , input
                [ type_ "password"
                , onInput (\p -> Mod <| UpdatePassword <| Password.create p)
                ]
                []
            , button
                [ onClick <| Mod TryLogin
                ]
                []
            ]
        ]
    ]
