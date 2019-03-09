module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation exposing (Key)
import Url exposing (Url)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css)
import Css exposing (px, absolute)
import Json.Encode exposing (Value)
import Json.Decode as Decode
import Message exposing (Msg(..))
import Port
import Nav
import Data.Session as Session exposing (Session)
import Data.Cache as Cache exposing (Cache)
import Data.Route as Route exposing (Route(..))
import Data.Theme exposing (Theme(..))
import Data.ProblemInfo exposing (ProblemInfo)
import Style.Theme
import Style.Global
import Page.Post
import Page.NotFound
import Page.Problem


-- Model

type Model
    = NotFound Session
    | Home Session
    | Post Page.Post.Model
    | Profile Session
    | Login Session
    | Problem Page.Problem.Model


-- Init


init : Value -> Url.Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    case Decode.decodeValue Cache.decoder flags of
        Ok cache ->
            ( defaultModel cache url key
            , Port.setCache cache
            )

        Err problem ->
            case problem of
                _ -> ( Problem {}, Cmd.none )
                -- Cache.Problem.BadVersion ->
                --     ( (Problem {}), Cmd.none )


defaultModel : Cache -> Url.Url -> Key -> Model
defaultModel cache url key =
    let
        route =
            Nav.urlToRoute url

        session =
            Session.init key

    in
        case route of
            Route.Home ->
                Home session

            _ ->
                NotFound session



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        session =
            toSession model


    in
        case msg of
            NoOp ->
                ( model, Cmd.none )

            LinkClicked urlRequest ->
                case urlRequest of
                    Browser.Internal url ->
                        ( model, Browser.Navigation.pushUrl session.key (Url.toString url) )

                    Browser.External href ->
                        ( model, Browser.Navigation.load href )

            UrlChanged url ->
                let
                    route =
                        Nav.urlToRoute url
                in
                ( { model | route = route }
                , Cmd.none
                )

            ToggleTheme ->
                let
                    newTheme =
                        case model.cache.theme of
                            Light ->
                                Dark

                            Dark ->
                                Light

                    cache =
                        model.cache

                    newCache =
                        { cache | theme = newTheme }
                in
                ( { model | cache = newCache }, Port.setCache newCache )


changeRoute : Route -> Model -> (Model, Cmd Msg)
changeRoute route model =
    let
        session =
            toSession model

    in
        case route of
            Route.NotFound ->
                NotFound session

            Route.Home ->
                Home session

            Route.Post slug ->
                Page.Post.init session

            Route.Profile ->
                Profile session

            Route.Login ->
                Login session

            Route.Problem page ->
                case page of
                    _ ->
                        Page.Problem.init
                            { session = session
                            , problemInfo =
                                { title = "Testing"
                                , description = "Not a real problem yet"
                                }
                            , action = Nothing
                            }



toSession : Model -> Session
toSession model =
    case model of
        NotFound session ->
            session

        Home session ->
            session

        Post postModel ->
            Page.Post.toSession postModel

        Profile session ->
            session

        Login session ->
            session

        Problem problemModel ->
            Page.Problem.toSession problemModel


-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


-- View


view : Model -> Document Msg
view model =
    { title = "Bits n' Bites"
    , body = List.map toUnstyled (body model)
    }


body : Model -> List (Html Msg)
body model =
    let
        theme =
            Cache.theme model.cache

    in
        [ div
            [ class "app"
            , css
                [ Css.position absolute
                , Css.top (px 0)
                , Css.bottom (px 0)
                , Css.left (px 0)
                , Css.right (px 0)
                , Css.backgroundColor (Style.Theme.background theme)
                , Css.color (Style.Theme.primaryFont theme)
                ]
            ]
            [ viewPage model ]
        , Style.Global.style
        ]


viewPage : Model -> Html Msg
viewPage model =
    case model of
        Post postModel ->
            Page.Post.view postModel

        NotFound session ->
            Page.NotFound.view session


-- Program


main : Program Value Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
