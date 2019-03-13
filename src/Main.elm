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
import Page.About
import Page.Donate
import Page.Home
import Page.NotFound
import Page.Post
import Page.Problem.CorruptCache
import Page.Problem.InvalidVersion
import Page.Profile
import Page.Redirect
import Style.Font as Font
import Style.Global
import Style.Theme
import Url exposing (Url)



-- Model


type alias Model =
    { problem : ProblemPage
    , pageModel : PageModel
    }


type PageModel
    = Redirect Global
    | NotFound Global
    | Home Page.Home.Model
    | Post Page.Post.Model
    | Donate Page.Donate.Model
    | About Page.About.Model
    | Profile Page.Profile.Model



-- | Login


type alias Global =
    ( Session, Cache )



-- Init


init : Value -> Url.Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        route =
            Route.fromUrl url

        session =
            Session.init key

        decoding =
            Cache.init flags

        cache =
            case decoding of
                Ok ( c, _ ) ->
                    c

                Err ( c, _ ) ->
                    c

        global =
            ( session, cache )

        problem =
            case decoding of
                Ok _ ->
                    None

                Err ( _, p ) ->
                    p

        ( model, cmd ) =
            changeRoute route
                { problem = None
                , pageModel =
                    Redirect
                        ( session, cache )
                }

        cmds =
            case decoding of
                Ok ( _, c ) ->
                    [ c, cmd ]

                Err _ ->
                    [ cmd ]
    in
    ( { model | problem = problem }, Cmd.batch cmds )



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update wrapper model =
    let
        ( session, cache ) =
            toGlobal model.pageModel
    in
    case wrapper of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Browser.Navigation.pushUrl session.key (Url.toString url) )

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
                ( newCache, cmd ) =
                    Cache.update msg cache
            in
            ( { model | pageModel = fromGlobal ( session, newCache ) model.pageModel }, cmd )


changeRoute : Route -> Model -> ( Model, Cmd Msg )
changeRoute route model =
    let
        global =
            toGlobal model.pageModel

        ( pageModel, cmd ) =
            case route of
                Route.NotFound ->
                    ( NotFound global, Cmd.none )

                Route.Home ->
                    Page.Home.init Home global

                Route.Post slug ->
                    Page.Post.init Post global

                Route.Donate ->
                    Page.Donate.init Donate global

                Route.About ->
                    Page.About.init About global

                Route.Profile ->
                    Page.Profile.init Profile global
    in
    ( { pageModel = pageModel
      , problem = None
      }
    , cmd
    )


toGlobal : PageModel -> ( Session, Cache )
toGlobal page =
    case page of
        Home model ->
            Page.Home.toGlobal model

        Post model ->
            Page.Post.toGlobal model

        About model ->
            Page.About.toGlobal model

        Donate model ->
            Page.Donate.toGlobal model

        Profile model ->
            Page.Profile.toGlobal model

        NotFound g ->
            g

        Redirect g ->
            g


fromGlobal : ( Session, Cache ) -> PageModel -> PageModel
fromGlobal global page =
    case page of
        Home model ->
            Home <| Page.Home.fromGlobal global model

        Post model ->
            Post <| Page.Post.fromGlobal global model

        About model ->
            About <| Page.About.fromGlobal global model

        Donate model ->
            Donate <| Page.Donate.fromGlobal global model

        Profile model ->
            Profile <| Page.Profile.fromGlobal global model

        NotFound _ ->
            NotFound global

        Redirect _ ->
            Redirect global



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
        ( session, cache ) =
            toGlobal model.pageModel

        theme =
            Cache.theme cache
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
    case model.problem of
        InvalidVersion ->
            Page.Problem.InvalidVersion.view <|
                Page.Problem.InvalidVersion.init

        CorruptCache msg ->
            Page.Problem.CorruptCache.view <|
                Page.Problem.CorruptCache.init msg

        None ->
            case model.pageModel of
                NotFound notFound ->
                    Page.NotFound.view notFound

                Redirect redirect ->
                    Page.Redirect.view redirect

                Home home ->
                    Page.Home.view home

                Post post ->
                    Page.Post.view post

                Donate post ->
                    Page.Donate.view post

                About post ->
                    Page.About.view post

                Profile post ->
                    Page.Profile.view post



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
