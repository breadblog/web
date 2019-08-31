module Page.Login exposing (Model, Msg, init, toGeneral, update, view)

import Api
import Css exposing (..)
import Data.General as General exposing (General, Msg(..))
import Data.Login
import Data.Password as Password exposing (Password)
import Data.Username as Username exposing (Username)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events as Events
import Http
import Json.Decode
import Style.Color as Color



{- Model -}


type Model
    = Model Internals


type alias Internals =
    { username : String
    , password : Password
    , error : Maybe String
    , general : General
    }


init : General -> ( Model, Cmd Msg )
init general =
    ( Model
        { username = Username.empty
        , password = Password.empty
        , error = Nothing
        , general = general
        }
    , Cmd.none
    )


toGeneral : Model -> General
toGeneral (Model internals) =
    internals.general



{- Message -}


type Msg
    = GotLogin (Result Http.Error Data.Login.Response)
    | Login
    | UpdateUsername Username
    | UpdatePassword Password
    | InputKeyUp Int
    | GeneralMsg General.Msg



{- Update -}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        (Model internals) =
            model

        general =
            internals.general
    in
    case msg of
        GotLogin res ->
            case res of
                Err err ->
                    ( Model { internals | error = Just "failed to login" }
                    , Cmd.none
                    )

                Ok info ->
                    let
                        ( updatedGeneral, generalCmd ) =
                            General.mapUser (always (Just info.uuid)) internals.general

                        cmd =
                            Cmd.map GeneralMsg generalCmd
                    in
                    ( Model { internals | general = updatedGeneral }
                    , cmd
                    )

        Login ->
            ( model
            , General.login internals.username internals.password general
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
                            Api.login internals.username internals.password internals.general

                        _ ->
                            Cmd.none
            in
            ( model
            , cmd
            )

        GeneralMsg generalMsg ->
            General.update generalMsg general
                |> Tuple.mapFirst (\g -> Model { internals | general = g })
                |> Tuple.mapSecond (Cmd.map GeneralMsg)



{- View -}


view : Model -> List (Html Msg)
view (Model internals) =
    let
        theme =
            General.theme internals.general
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
                , Username.onInput UpdateUsername
                , onKeyUp InputKeyUp
                ]
                []
            , input
                [ type_ "password"
                , Password.onInput UpdatePassword
                , onKeyUp InputKeyUp
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
                    [ Events.onClick <| GeneralMsg TryLogout
                    ]
                    [ text "logout" ]
                , button
                    [ Events.onClick TryLogin
                    ]
                    [ text "submit" ]
                ]
            ]
        ]
    ]


onKeyUp : (Int -> Msg) -> Attribute Msg
onKeyUp tagger =
    Events.on "keyup" <| Json.Decode.map tagger Events.keyCode
