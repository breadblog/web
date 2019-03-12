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
import Page.Home
import Page.NotFound
import Page.Post
import Page.Problem.CorruptCache
import Page.Problem.InvalidVersion
import Page.Redirect
import Style.Font as Font
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
    = Redirect
    | NotFound
    | Home Page.Home.Model
    | Post Page.Post.Model
    | Profile
    | Login
    | About
    | Donate



-- Init


init : Value -> Url.Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        ( cache, problem ) =
            case Cache.init flags of
                Ok c ->
                    ( c, None )

                Err ( c, p ) ->
                    ( c, p )

        model =
            { cache = cache
            , problem = problem
            , session = session
            , pageModel = Redirect
            }

        route =
            Route.fromUrl url

        session =
            Session.init key
    in
    changeRoute route model



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update wrapper model =
    case wrapper of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Browser.Navigation.pushUrl model.session.key (Url.toString url) )

                Browser.External href ->
                    ( model, Browser.Navigation.load href )

        UrlChanged url ->
            let
                route =
                    Route.fromUrl url
            in
            changeRoute route model

        CacheMsg msg ->
            let
                ( cache, cmd ) =
                    Cache.update msg model.cache
            in
            ( { model | cache = cache }, cmd )


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
                    Page.Home.init Home theme

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

                Route.About ->
                    ( About
                    , Cmd.none
                    )

                Route.Donate ->
                    ( Donate
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
            , Css.fontFamilies Font.montserrat
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
        InvalidVersion ->
            Page.Problem.InvalidVersion.view <|
                Page.Problem.InvalidVersion.init

        CorruptCache msg ->
            Page.Problem.CorruptCache.view <|
                Page.Problem.CorruptCache.init msg

        None ->
            case model.pageModel of
                Redirect ->
                    Page.Redirect.view theme

                Home home ->
                    Page.Home.view home

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
