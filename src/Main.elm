module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation exposing (Key)
import Css exposing (absolute, px)
import Data.General as General exposing (General)
import Data.Route as Route exposing (Route(..))
import Data.Theme exposing (Theme(..))
import Data.Problem as Problem exposing (Problem, Description(..))
import Data.Markdown as Markdown exposing (Markdown)
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
import Page.NotFound
import Page.Post
import Page.Redirect
import Page.Problems
import Style.Color
import Style.Font as Font
import Style.Global
import Url exposing (Url)
import Update



-- Model --


type Model
    = Redirect General
    | NotFound General
    | Donate Page.Donate.Model
    | About Page.About.Model
    | Home Page.Home.Model
    | Post Page.Post.Model
    | Changelog Page.Changelog.Model



-- Message --


type alias Msg =
    Compound InternalMsg


type InternalMsg
    = HomeMsg Page.Home.Msg
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

        ( general, cmd ) =
            General.init key flags

        -- TODO: do something with cmd

    in
        changeRoute route <| Redirect general



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

                _ ->
                    -- TODO: Error handling (impossible state)
                    let
                        problem =
                            Problem.create
                                ""
                                (MarkdownError <| Markdown.create "")
                                Nothing

                        updatedGeneral =
                            General.pushProblem problem general

                    in
                    ( fromGeneral updatedGeneral model , Cmd.none )


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
            toGeneral model

        ( pageModel, cmd ) =
            case route of
                Route.NotFound ->
                    ( NotFound general, Cmd.none )

                Route.Donate ->
                    Page.Donate.init general Donate (toMsg DonateMsg)

                Route.About ->
                    Page.About.init general About (toMsg AboutMsg)

                Route.Home ->
                    Page.Home.init general Home (toMsg HomeMsg)

                Route.Post uuid ->
                    Page.Post.init uuid general Post (toMsg PostMsg)

                Route.Changelog ->
                    Page.Changelog.init general Changelog (toMsg ChangelogMsg)
    in
    ( pageModel, cmd )


toGeneral : Model -> General
toGeneral page =
    case page of
        Home model ->
            Page.Home.toGeneral model

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


fromGeneral : General -> Model -> Model
fromGeneral general page =
    case page of
        Home model ->
            Home <| Page.Home.fromGeneral general model

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



-- Subscriptions --


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



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
