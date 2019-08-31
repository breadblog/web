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
import Url exposing (Url)



{- Model -}


type Model
    = Model Key Page


type Page
    = Redirect General
    | NotFound General
    | Home Page.Home.Model
    | Post Page.Post.Model


init : Value -> Url.Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        route =
            Route.fromUrl url

        ( general, generalCmd ) =
            General.init key route flags

        ( model, routeCmd ) =
            changeRoute route <| Model key <| Redirect general

        cmd =
            Cmd.batch
                [ routeCmd
                , Cmd.map GeneralMsg generalCmd
                ]
    in
    ( model, cmd )



{- Message -}


type Msg
    = OnUrlRequest Browser.UrlRequest
    | OnUrlChange Url
    | ChangedRoute (Maybe Route)
    | PostMsg Page.Post.Msg
    | HomeMsg Page.Home.Msg
    | GeneralMsg General.Msg



{- Update -}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


changeRoute : Route -> Model -> ( Model, Cmd Msg )
changeRoute route (Model key page) =
    let
        general =
            page
                |> toGeneral
                |> General.mapRoute key (always route)

        ( updatedPage, cmd ) =
            case route of
                Route.Home ->
                    Page.Home.init general
                        |> Tuple.mapFirst Home
                        |> Tuple.mapSecond (Cmd.map HomeMsg)

                Route.NotFound ->
                    ( NotFound general, Cmd.none )

                Route.Post postRoute ->
                    Page.Post.init general postRoute
                        |> Tuple.mapFirst Post
                        |> Tuple.mapSecond (Cmd.map PostMsg)
    in
    ( Model key updatedPage
    , cmd
    )


toGeneral : Page -> General
toGeneral page =
    case page of
        Home model ->
            Page.Home.toGeneral model

        Post model ->
            Page.Post.toGeneral model

        NotFound g ->
            g

        Redirect g ->
            g


mapGeneral : (General -> General) -> Page -> Page
mapGeneral transform page =
    case page of
        Home model ->
            Home <| Page.Home.mapGeneral transform model

        Post model ->
            Post <| Page.Post.mapGeneral transform model

        NotFound g ->
            NotFound (transform g)

        Redirect g ->
            Redirect (transform g)



{- Subscriptions -}


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map GeneralMsg General.networkSub
        , Sub.map GeneralMsg General.fullscreenSub
        ]



{- View -}


view : Model -> Document Msg
view model =
    { title = "Bits n' Bites"
    , body = List.map toUnstyled (body model)
    }


body : Model -> List (Html Msg)
body (Model _ page) =
    let
        general =
            toGeneral page

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
        (viewPage page)
    , Style.Global.style theme
    ]


viewPage : Page -> List (Html Msg)
viewPage page =
    let
        general =
            toGeneral page

        problems =
            General.problems general

        numProblems =
            List.length problems
    in
    case numProblems of
        -- No problems
        0 ->
            case page of
                NotFound model ->
                    Page.NotFound.view model

                Redirect model ->
                    Page.Redirect.view model

                Post model ->
                    List.map (Html.Styled.map PostMsg) (Page.Post.view model)

                Home model ->
                    List.map (Html.Styled.map HomeMsg) (Page.Home.view model)

        -- Problems exist
        _ ->
            problems
                |> Page.Problems.view
                |> Html.Styled.map GeneralMsg
                |> List.singleton



-- Program --


main : Program Value Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = OnUrlChange
        , onUrlRequest = OnUrlRequest
        }
