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
import Message exposing (Compound(..), Msg(..))
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
    = Home Page.Home.Model
    | Redirect Context
    | NotFound Context
    | Donate Page.Donate.Model
    | About Page.About.Model
    | Login Page.Login.Model
    | Post Page.Post.Model
    | Changelog Page.Changelog.Model



-- Message --


type Msg
    = HomeMsg Page.Home.Msg
    | LoginMsg Page.Login.Msg
    | PostMsg Page.Post.Msg
    | DonateMsg Page.Donate.Msg
    | AboutMsg Page.About.Msg
    | ChangelogMsg Page.Changelog.Msg


toMsg : (e -> InternalMsg) -> e -> Msg
toMsg transform msg =
    Mod <| transform <| msg



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
update compound model =
    let
        general =
            toContext model

        key =
            Context.key general
    in
    case compound of
        Global msg ->
            case msg of
                LinkClicked urlRequest ->
                    case urlRequest of
                        Browser.Internal url ->
                            ( model, Browser.Navigation.pushUrl key (Url.toString url) )

                        Browser.External href ->
                            ( model, Browser.Navigation.load href )

                UrlChanged url ->
                    let
                        route =
                            Route.fromUrl url
                    in
                    changeRoute route model

                ContextMsg generalMsg ->
                    let
                        ( updatedContext, generalCmd ) =
                            Context.update generalMsg general

                        updatedModel =
                            fromContext updatedContext model

                        cmd =
                            Cmd.map (\c -> Global <| ContextMsg c) generalCmd
                    in
                    ( updatedModel, cmd )

                NoOp ->
                    ( model, Cmd.none )

        Mod msg ->
            case ( model, msg ) of
                ( Home homeModel, HomeMsg homeMsg ) ->
                    updatePage Home HomeMsg Page.Home.update homeModel homeMsg model

                ( Post postModel, PostMsg postMsg ) ->
                    updatePage Post PostMsg Page.Post.update postModel postMsg model

                ( Login loginModel, LoginMsg loginMsg ) ->
                    updatePage Login LoginMsg Page.Login.update loginModel loginMsg model

                _ ->
                    let
                        problem =
                            Problem.create
                                "Failed to Forward"
                                (MarkdownError <| Markdown.create "Failed to forward `ModMsg` in `Main.elm`")
                                Nothing

                        updatedContext =
                            Context.pushProblem problem general
                    in
                    ( fromContext updatedContext model, Cmd.none )


changeRoute : Route -> Model -> ( Model, Cmd Msg )
changeRoute route model =
    let
        general =
            toContext model

        ( pageModel, cmd ) =
            case route of
                Route.Home ->
                    Page.Home.init general Home (toMsg HomeMsg)

                Route.Login ->
                    Page.Login.init general Login (toMsg LoginMsg)

                Route.NotFound ->
                    ( NotFound general, Cmd.none )

                Route.Donate ->
                    Page.Donate.init general Donate (toMsg DonateMsg)

                Route.About ->
                    Page.About.init general About (toMsg AboutMsg)

                Route.Post uuid ->
                    Page.Post.init uuid general Post (toMsg PostMsg)

                Route.Changelog ->
                    Page.Changelog.init general Changelog (toMsg ChangelogMsg)
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


fromContext : Context -> Model -> Model
fromContext general page =
    case page of
        Home model ->
            Home <| Page.Home.fromContext general model

        Login model ->
            Login <| Page.Login.fromContext general model

        Post model ->
            Post <| Page.Post.fromContext general model

        About model ->
            About <| Page.About.fromContext general model

        Donate model ->
            Donate <| Page.Donate.fromContext general model

        Changelog model ->
            Changelog <| Page.Changelog.fromContext general model

        NotFound _ ->
            NotFound general

        Redirect _ ->
            Redirect general



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
