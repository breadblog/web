module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation exposing (Key)
import Css exposing (absolute, px)
import Data.Cache as Cache exposing (Cache)
import Data.General as General exposing (General)
import Data.Route as Route exposing (ProblemPage(..), Route(..))
import Data.Session as Session exposing (Session)
import Data.Theme exposing (Theme(..))
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css)
import Json.Decode as Decode
import Json.Encode exposing (Value)
import Message exposing (Compound(..), Msg(..))
import Page.About
import Page.Donate
import Page.Home
import Page.NotFound
import Page.Post
import Page.Problem.CorruptCache
import Page.Problem.InvalidVersion
import Page.Profile
import Page.Redirect
import Style.Color
import Style.Font as Font
import Style.Global
import Url exposing (Url)



-- Model --


type alias Model =
    { problem : ProblemPage
    , pageModel : PageModel
    }


type PageModel
    = Redirect General
    | NotFound General
    | Donate General
    | About General
    | Home Page.Home.Model
    | Post Page.Post.Model
    | Profile Page.Profile.Model



-- Message --


type alias Msg =
    Compound InternalMsg


type InternalMsg
    = HomeMsg Page.Home.Msg
    | PostMsg Page.Post.Msg
    | ProfileMsg Page.Profile.Msg



-- Init --


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

        general =
            General.init session cache

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
                    Redirect <|
                        General.init session cache
                }

        cmds =
            case decoding of
                Ok ( _, c ) ->
                    [ c, cmd ]

                Err _ ->
                    [ cmd ]
    in
    ( { model | problem = problem }, Cmd.batch cmds )



-- Update --


update : Msg -> Model -> ( Model, Cmd Msg )
update compound model =
    let
        general =
            toGeneral model.pageModel

        session =
            General.session general

        cache =
            General.cache general
    in
    case compound of
        Global msg ->
            case msg of
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

                CacheMsg cacheMsg ->
                    let
                        ( newCache, cmd ) =
                            Cache.update cacheMsg cache
                    in
                    ( { model | pageModel = fromGeneral (General.init session newCache) model.pageModel }, cmd )

                NoOp ->
                    ( model, Cmd.none )

        Mod msg ->
            case ( model.pageModel, msg ) of
                ( Home homeModel, HomeMsg homeMsg ) ->
                    updatePage Home HomeMsg Page.Home.update homeModel homeMsg model

                ( Post postModel, PostMsg postMsg ) ->
                    updatePage Post PostMsg Page.Post.update postModel postMsg model

                ( Profile profileModel, ProfileMsg profileMsg ) ->
                    updatePage Profile ProfileMsg Page.Profile.update profileModel profileMsg model

                _ ->
                    -- TODO: Error handling (impossible state)
                    ( model, Cmd.none )


type alias Update msg model =
    msg -> model -> ( model, Cmd msg )


updatePage : (modModel -> PageModel) -> (modMsg -> InternalMsg) -> Update modMsg modModel -> modModel -> modMsg -> Model -> ( Model, Cmd Msg )
updatePage transformModel transformMsg modUpdate modModel modMsg model =
    let
        ( newModel, modCmd ) =
            modUpdate modMsg modModel

        cmd =
            Cmd.map (\m -> Mod <| transformMsg m) modCmd
    in
    ( { model | pageModel = transformModel newModel }, cmd )


toMsg : (m -> InternalMsg) -> m -> Msg
toMsg transform msg =
    Mod <| transform msg


changeRoute : Route -> Model -> ( Model, Cmd Msg )
changeRoute route model =
    let
        general =
            toGeneral model.pageModel

        ( pageModel, cmd ) =
            case route of
                Route.NotFound ->
                    ( NotFound general, Cmd.none )

                Route.Donate ->
                    ( Donate general, Cmd.none )

                Route.About ->
                    ( About general, Cmd.none )

                Route.Home ->
                    Page.Home.init Home general

                Route.Post slug ->
                    Page.Post.init Post general

                Route.Profile ->
                    Page.Profile.init Profile general
    in
    ( { pageModel = pageModel
      , problem = None
      }
    , cmd
    )


toGeneral : PageModel -> General
toGeneral page =
    case page of
        Home model ->
            Page.Home.toGeneral model

        Post model ->
            Page.Post.toGeneral model

        Profile model ->
            Page.Profile.toGeneral model

        About g ->
            g

        Donate g ->
            g

        NotFound g ->
            g

        Redirect g ->
            g


fromGeneral : General -> PageModel -> PageModel
fromGeneral general page =
    case page of
        Home model ->
            Home <| Page.Home.fromGeneral general model

        Post model ->
            Post <| Page.Post.fromGeneral general model

        Profile model ->
            Profile <| Page.Profile.fromGeneral general model

        About model ->
            NotFound general

        Donate model ->
            Donate general

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
            toGeneral model.pageModel

        cache =
            General.cache general

        theme =
            Cache.theme cache
    in
    [ div
        [ class "app"
        , css
            [ Css.position Css.relative
            , Css.height <| Css.pct 100
            , Css.width <| Css.pct 100
            , Css.backgroundColor (Style.Color.background theme)
            , Css.color (Style.Color.primaryFont theme)
            , Css.fontFamilies Font.montserrat
            ]
        ]
        [ viewPage model ]
    , Style.Global.style theme
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

                Donate donate ->
                    Page.Donate.view donate

                About about ->
                    Page.About.view about

                Home home ->
                    Html.Styled.map
                        (Message.map HomeMsg)
                        (Page.Home.view home)

                Post post ->
                    Html.Styled.map
                        (Message.map PostMsg)
                        (Page.Post.view post)

                Profile profile ->
                    Html.Styled.map
                        (Message.map ProfileMsg)
                        (Page.Profile.view profile)



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
