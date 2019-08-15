module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation exposing (Key)
import Css exposing (absolute, px)
import Data.General as General exposing (General)
import Data.Markdown as Markdown exposing (Markdown)
import Data.Problem as Problem exposing (Description(..), Problem)
import Data.Route as Route exposing (Route(..))
import Data.Theme exposing (Theme(..))
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, id)
import Json.Decode as Decode
import Json.Encode exposing (Value)
import Message exposing (Compound(..), Msg(..))
import Page.About
import Page.Changelog
import Page.Donate
import Page.Home
import Page.Login
import Page.NotFound
import Page.Offline
import Page.Post
import Page.Problems
import Page.Redirect
import Style.Color
import Style.Font as Font
import Style.Global
import Update
import Url exposing (Url)



-- Model --


type Model
    = Redirect General
    | NotFound General
    | Offline General
    | Donate Page.Donate.Model
    | About Page.About.Model
    | Home Page.Home.Model
    | Login Page.Login.Model
    | Post Page.Post.Model
    | Changelog Page.Changelog.Model



-- Message --


type alias Msg =
    Compound InternalMsg


type InternalMsg
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
            General.init route key flags

        ( model, routeCmd ) =
            changeRoute route <| Redirect general

        cmd =
            Cmd.batch
                [ routeCmd
                , Cmd.map
                    (\m ->
                        m
                            |> GeneralMsg
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
            toGeneral model

        key =
            General.key general
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

                GeneralMsg generalMsg ->
                    let
                        ( updatedGeneral, generalCmd ) =
                            General.update generalMsg general

                        updatedModel =
                            fromGeneral updatedGeneral model

                        cmd =
                            Cmd.map (\c -> Global <| GeneralMsg c) generalCmd
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

                        updatedGeneral =
                            General.pushProblem problem general
                    in
                    ( fromGeneral updatedGeneral model, Cmd.none )


type alias Update msg model =
    msg -> model -> Update.Output msg model


updatePage : (modModel -> Model) -> (modMsg -> InternalMsg) -> Update modMsg modModel -> modModel -> modMsg -> Model -> ( Model, Cmd Msg )
updatePage transformModel transformMsg modUpdate modModel modMsg model =
    let
        output =
            modUpdate modMsg modModel

        cmd =
            Cmd.map (Message.map transformMsg) output.cmd

        updatedModel =
            fromGeneral output.general <| transformModel output.model
    in
    ( updatedModel, cmd )


changeRoute : Route -> Model -> ( Model, Cmd Msg )
changeRoute route model =
    let
        general =
            General.updateRoute route (toGeneral model)

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

                Route.Post postType ->
                    Page.Post.init postType general Post (toMsg PostMsg)

                Route.Changelog ->
                    Page.Changelog.init general Changelog (toMsg ChangelogMsg)

                Route.Offline ->
                    ( Offline general, Cmd.none )
    in
    ( pageModel
    , Cmd.batch
        [ cmd
        , Route.changeRoute route
        ]
    )


toGeneral : Model -> General
toGeneral page =
    case page of
        Home model ->
            Page.Home.toGeneral model

        Login model ->
            Page.Login.toGeneral model

        Post model ->
            Page.Post.toGeneral model

        About model ->
            Page.About.toGeneral model

        Donate model ->
            Page.Donate.toGeneral model

        Changelog model ->
            Page.Changelog.toGeneral model

        NotFound g ->
            g

        Redirect g ->
            g

        Offline g ->
            g


fromGeneral : General -> Model -> Model
fromGeneral general page =
    case page of
        Home model ->
            Home <| Page.Home.fromGeneral general model

        Login model ->
            Login <| Page.Login.fromGeneral general model

        Post model ->
            Post <| Page.Post.fromGeneral general model

        About model ->
            About <| Page.About.fromGeneral general model

        Donate model ->
            Donate <| Page.Donate.fromGeneral general model

        Changelog model ->
            Changelog <| Page.Changelog.fromGeneral general model

        NotFound _ ->
            NotFound general

        Redirect _ ->
            Redirect general

        Offline _ ->
            Offline general



-- Subscriptions --


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map (GeneralMsg >> Global) General.networkSub
        , Sub.map (GeneralMsg >> Global) General.fullscreenSub
        , Sub.map (GeneralMsg >> Global) General.interval
        , Sub.map (GeneralMsg >> Global) General.onResize
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
            toGeneral model

        theme =
            General.theme general
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
            toGeneral model

        problems =
            General.problems general

        numProblems =
            List.length problems
    in
    case numProblems of
        -- No problems
        0 ->
            case model of
                NotFound notFound ->
                    Page.NotFound.view notFound

                Offline offline ->
                    Page.Offline.view offline

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
                |> Html.Styled.map (\c -> Global <| GeneralMsg c)
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
