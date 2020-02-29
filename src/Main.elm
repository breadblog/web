module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation exposing (Key)
import Css
import Data.Context as Context exposing (Context)
import Data.Markdown as Markdown
import Data.Problem as Problem exposing (Description(..))
import Data.Route as Route exposing (Route(..))
import Data.Theme exposing (Theme(..))
import Html.Styled exposing (Html, toUnstyled, div)
import Html.Styled.Attributes exposing (css, id)
import Json.Encode exposing (Value)
import Page.About
import Page.Changelog
import Page.Donate
import Page.Home
import Page.Login
import Page.NotFound
import Page.Post
import Page.Problems
import Page.Redirect
import Style.Color
import Style.Font as Font
import Style.Global
import Url


-- Model --


type Model
    = Redirect Context
    | NotFound Context
    | Home Page.Home.Model
    | Login Page.Login.Model
    | Post Page.Post.Model
    | Donate Page.Donate.Model
    | About Page.About.Model
    | Changelog Page.Changelog.Model



-- Message --


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | HomeMsg Page.Home.Msg
    | LoginMsg Page.Login.Msg
    | PostMsg Page.Post.Msg
    | DonateMsg Page.Donate.Msg
    | AboutMsg Page.About.Msg
    | ChangelogMsg Page.Changelog.Msg



-- Init --


init : Value -> Url.Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        route =
            Route.fromUrl url

        ( general, generalCmd ) =
            Context.init key flags

        ( model, routeCmd ) =
            changeRoute route <| Redirect general

        cmd =
            Cmd.batch
                [ routeCmd
                , Cmd.map
                    (\m ->
                        m
                            |> ContextMsg
                            |> Global
                    )
                    generalCmd
                ]
    in
    ( model, cmd )



-- Update --


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        general =
            toContext model

        key =
            Context.key general
    in
    case (msg, model) of
        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Browser.Navigation.pushUrl key (Url.toString url) )

                Browser.External href ->
                    ( model, Browser.Navigation.load href )

        ( UrlChanged url, _ ) ->
            let
                route =
                    Route.fromUrl url
            in
            changeRoute route model

        ( HomeMsg homeMsg, Home homeModel ) ->
            toPage HomeMsg Home <| Page.Home.update homeMsg homeModel

        ( LoginMsg loginMsg, Login loginModel ) ->
            toPage LoginMsg Login <| Page.Login.update loginMsg loginModel

        ( PostMsg postMsg, Post postModel ) ->
            toPage PostMsg Post <| Page.Post.update postMsg postModel

        ( DonateMsg donateMsg, Donate donateModel ) ->
            toPage DonateMsg Donate <| Page.Donate.update donateMsg donateModel

        ( AboutMsg aboutMsg, About aboutModel ) ->
            toPage AboutMsg About <| Page.About.update aboutMsg aboutModel

        ( ChangelogMsg changelogMsg, Changelog changelogModel ) ->
            toPage ChangelogMsg Changelog <| Page.Changelog.update changelogMsg changelogModel

        _ ->
            ( model, Cmd.none )


toPage : (msg -> Msg) -> (model -> Model) -> ( model, Cmd msg ) -> ( Model, Cmd Msg )
toPage transformMsg transformModel ( model, cmd ) =
    ( transformModel model
    , Cmd.map transformMsg cmd
    )


changeRoute : Route -> Model -> ( Model, Cmd Msg )
changeRoute route model =
    let
        context =
            toContext model

        ( pageModel, cmd ) =
            case route of
                Route.Home ->
                    toPage HomeMsg Home <| Page.Home.init context

                Route.Login ->
                    toPage LoginMsg Login <| Page.Login.init context

                Route.Donate ->
                    toPage DonateMsg Donate <| Page.Donate.init context

                Route.About ->
                    toPage AboutMsg About <| Page.About.init context

                Route.Post postType ->
                    toPage PostMsg Post <| Page.Post.init context postType

                Route.Changelog ->
                    toPage ChangelogMsg Changelog <| Page.Changelog.init context

                Route.NotFound ->
                    ( NotFound context, Cmd.none )
    in
    ( pageModel
    , Cmd.batch
        [ cmd
        , Route.changeRoute route
        ]
    )


toContext : Model -> Context
toContext page =
    case page of
        Home model ->
            Page.Home.toContext model

        Login model ->
            Page.Login.toContext model

        Post model ->
            Page.Post.toContext model

        About model ->
            Page.About.toContext model

        Donate model ->
            Page.Donate.toContext model

        Changelog model ->
            Page.Changelog.toContext model

        NotFound g ->
            g

        Redirect g ->
            g


-- Subscriptions --


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map (ContextMsg >> Global) Context.networkSub
        , Sub.map (ContextMsg >> Global) Context.fullscreenSub
        ]



-- View --


view : Model -> Document Msg
view model =
    { title = "Bits n' Bites"
    , body = List.map toUnstyled (body model)
    }


body : Model -> List (Html Msg)
body model =
    let
        general =
            toContext model

        theme =
            Context.theme general
    in
    [ div
        [ id "app"
        , css
            [ Css.position Css.relative
            , Css.height <| Css.pct 100
            , Css.width <| Css.pct 100
            , Css.backgroundColor (Style.Color.background theme)
            , Css.color (Style.Color.primaryFont theme)
            , Css.fontFamilies Font.montserrat
            ]
        ]
        (viewPage model)
    , Style.Global.style theme
    ]


viewPage : Model -> List (Html Msg)
viewPage model =
    let
        general =
            toContext model

        problems =
            Context.problems general

        numProblems =
            List.length problems
    in
    case numProblems of
        -- No problems
        0 ->
            case model of
                NotFound notFound ->
                    Page.NotFound.view notFound

                Redirect redirect ->
                    Page.Redirect.view redirect

                Donate donate ->
                    List.map
                        (Html.Styled.map (Message.map DonateMsg))
                        (Page.Donate.view donate)

                About about ->
                    List.map
                        (Html.Styled.map (Message.map AboutMsg))
                        (Page.About.view about)

                Home home ->
                    List.map
                        (Html.Styled.map (Message.map HomeMsg))
                        (Page.Home.view home)

                Login login ->
                    List.map
                        (Html.Styled.map (Message.map LoginMsg))
                        (Page.Login.view login)

                Post post ->
                    List.map
                        (Html.Styled.map (Message.map PostMsg))
                        (Page.Post.view post)

                Changelog changelog ->
                    List.map
                        (Html.Styled.map (Message.map ChangelogMsg))
                        (Page.Changelog.view changelog)

        -- Problems exist
        _ ->
            problems
                |> Page.Problems.view
                |> Html.Styled.map (\c -> Global <| ContextMsg c)
                |> List.singleton



-- Program --


main : Program Value Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = \u -> Global <| UrlChanged u
        , onUrlRequest = \r -> Global <| LinkClicked r
        }
