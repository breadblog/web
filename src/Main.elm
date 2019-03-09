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
import Data.Route as Route exposing (Route(..), ProblemPage(..))
import Data.Theme exposing (Theme(..))
import Style.Theme
import Style.Global
import Page.Post
import Page.NotFound
import Page.Problem


-- Model


{-
    Application model

    Modelling the data in this way is potentially dangerous, because it is
    entirely possible that `model.session` and `model.pageModel.session` is different,
    which would ideally be impossible state. Same for `model.cache` and
    `model.pageModel.cache`.

    TODO: make this impossible state impossible without
    * Losing cache or session and having to remake/retrieve it (performance/usability cost)
    * Requiring ALL pages to take in session and/or cache, unless this is deemed acceptable
-}
type alias Model =
    { cache : Cache
    , session : Session
    , pageModel : PageModel
    }

type PageModel
    = NotFound
    | Home
    | Post Page.Post.Model
    | Profile
    | Login
    | Problem ProblemPage


-- Init


init : Value -> Url.Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        session =
            Session.init key

    in
        case Cache.init flags of
            Ok cache ->
                ( defaultModel cache url key
                , Port.setCache cache
                )

            Err (cache, problemPage) ->
                ( defaultModel cache url key
                , Browser.Navigation.pushUrl session.key (Nav.routeToPath (Route.Problem problemPage))
                )



defaultModel : Cache -> Url.Url -> Key -> Model
defaultModel cache url key =
    let
        route =
            Nav.urlToRoute url

        session =
            Session.init key

        pageModel =
            case route of
                Route.Home ->
                    Home

                _ ->
                    NotFound

    in
        { cache = cache
        , session = session
        , pageModel = pageModel
        }



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Browser.Navigation.pushUrl model.session.key (Url.toString url) )

                Browser.External href ->
                    ( model, Browser.Navigation.load href )


        ToggleTheme ->
            let
                theme =
                    Cache.theme model.cache
                newTheme =
                    case (Cache.theme model.cache) of
                        Light ->
                            Dark

                        Dark ->
                            Light

                newCache =
                    Cache.mapTheme (\n -> newTheme) model.cache
            in
                ( { model | cache = newCache }, Port.setCache newCache )
        UrlChanged url ->
            let
                route =
                    Nav.urlToRoute url
            in
                changeRoute route model

changeRoute : Route -> Model -> (Model, Cmd Msg)
changeRoute route model =
    let
        session =
            model.session
        
        cache =
            model.cache

        theme =
            Cache.theme cache

        (pageModel, cmd) =
            case route of
                Route.Problem problemPage ->
                    ( Problem problemPage
                    , Cmd.none
                    )

                Route.NotFound ->
                    ( NotFound
                    , Cmd.none
                    )

                Route.Home ->
                    ( Home
                    , Cmd.none
                    )

                Route.Post slug ->
                    Page.Post.init Post theme

                Route.Profile ->
                    ( Profile
                    , Cmd.none
                    )

                Route.Login ->
                    ( Login
                    , Cmd.none
                    )

    in
        ( { session = session
            , cache = cache
            , pageModel = pageModel
            }
        , cmd
        )


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
    let
        theme =
            Cache.theme model.cache

    in
        case model.pageModel of
            Post post ->
                Page.Post.view post

            _ ->
                Page.NotFound.view


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
