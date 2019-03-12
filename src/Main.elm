module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation exposing (Key)
import Css exposing (absolute, px)
import Data.Cache as Cache exposing (Cache)
import Data.Route as Route exposing (ProblemPage(..), Route(..))
import Data.Session as Session exposing (Session)
import Data.Theme exposing (Theme(..))
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css)
import Json.Decode as Decode
import Json.Encode exposing (Value)
import Message exposing (Msg(..))
import Nav
import Page.NotFound
import Page.Post
import Page.Problem.InvalidVersion
import Page.Problem.CorruptCache
import Port
import Style.Global
import Style.Theme
import Url exposing (Url)



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
    , problem : ProblemPage
    , session : Session
    , pageModel : PageModel
    }


type PageModel
    = NotFound
    | Home
    | Post Page.Post.Model
    | Profile
    | Login


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

        Err ( cache, problem ) ->
            let
                model = defaultModel cache url key
            in
                ({ model | problem = problem }, Cmd.none)


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
    , problem = None
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
                    case Cache.theme model.cache of
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


changeRoute : Route -> Model -> ( Model, Cmd Msg )
changeRoute route model =
    let
        session =
            model.session

        cache =
            model.cache

        theme =
            Cache.theme cache

        ( pageModel, cmd ) =
            case route of
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
      , problem = None
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
    case model.problem of
        None ->
            case model.pageModel of
                Post post ->
                    Page.Post.view post

                _ ->
                    Page.NotFound.view

        InvalidVersion ->
            Page.Problem.InvalidVersion.view
                <| Page.Problem.InvalidVersion.init

        CorruptCache msg ->
            Page.Problem.CorruptCache.view
                <| Page.Problem.CorruptCache.init msg



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
