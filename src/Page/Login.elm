module Page.Login exposing (Model, Msg, fromContext, init, toContext, update, view)

import Endpoint
import Css exposing (..)
import Data.Context as Context exposing (Context, Msg(..))
import Data.Login
import Data.Password as Password exposing (Password)
import Data.Route as Route exposing (Route(..))
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Html.Styled.Events as Events exposing (onClick, onInput)
import Http
import Json.Decode
import Page
import Style.Color as Color



{- Model -}


type alias Model =
    { context : Context
    , username : String
    , password : Password
    , error : Maybe String
    }


init : Context -> ( Model, Cmd Msg )
init context =
    ( { context = context
      , username = ""
      , password = Password.create ""
      , error = Nothing
      }
    , Cmd.none
    )


toContext : Model -> Context
toContext =
    Page.toContext


fromContext : Context -> Model -> Model
fromContext =
    Page.fromContext



{- Message -}


type Msg
    = OnLogin (Result Http.Error Data.Login.Response)
    | TryLogin
    | UpdateUsername String
    | UpdatePassword Password
    | InputKeyUp Int
    | Ctx Context.Msg



{- Update -}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ context } as model) =
    case msg of
        OnLogin res ->
            case res of
                Err _ ->
                    ( { model
                        | error = Just "failed to login"
                      }
                    , Cmd.none
                    )

                Ok info ->
                    let
                        ( updatedContext, cmd ) =
                            Context.mapUser info.uuid context
                    in
                    ( { model
                        | context = updatedContext
                      }
                    , Cmd.map Ctx cmd
                    )

        TryLogin ->
            ( model, attemptLogin model )

        UpdateUsername username ->
            ( { model | username = username }, Cmd.none )

        UpdatePassword password ->
            ( { model | password = password }, Cmd.none )

        InputKeyUp code ->
            ( model
            , case code of
                13 ->
                    attemptLogin model

                _ ->
                    Cmd.none
            )

        Ctx contextMsg ->
            let
                ( updatedContext, cmd ) =
                    Context.update contextMsg context
            in
            ( { model | context = updatedContext }
            , Cmd.map Ctx cmd
            )


attemptLogin : Model -> Cmd Msg
attemptLogin { context, username, password } =
    let
        mode =
            Context.getMode context
    in
    Api.create
        { expect = Http.expectJson OnLogin <| Data.Login.decodeResponse
        , body =
            Data.Login.Request username password
                |> Data.Login.encodeRequest
                |> Http.jsonBody
        , url = Api.url mode "/login/"
        }



{- View -}


view : Model -> List (Html Msg)
view { context } =
    let
        theme =
            Context.getTheme context
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
                , onInput (\u -> UpdateUsername u)
                , onKeyUp (\i -> InputKeyUp i)
                ]
                []
            , input
                [ type_ "password"
                , onInput (\p -> UpdatePassword <| Password.create p)
                , onKeyUp (\i -> InputKeyUp i)
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
                    [ onClick <| Ctx TryLogout
                    ]
                    [ text "logout" ]
                , button
                    [ onClick TryLogin
                    ]
                    [ text "submit" ]
                ]
            ]
        ]
    ]


onKeyUp : (Int -> Msg) -> Attribute Msg
onKeyUp tagger =
    Events.on "keyup" <| Json.Decode.map tagger Events.keyCode
