module Page.Post exposing (Model, Msg, fromGeneral, init, toGeneral, update, view)

import Config
import Data.Author as Author exposing (Author)
import Data.Body as Body exposing (Body)
import Data.Cache as Cache exposing (Cache)
import Data.General as General exposing (General)
import Data.Post as Post exposing (Full, Post)
import Data.Route exposing (Route(..))
import Data.Session exposing (Session)
import Data.Theme exposing (Theme)
import Data.UUID as UUID exposing (UUID)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events
import Http
import Message exposing (Compound(..), Msg(..))
import Style.Post
import Time
import View.Markdown as Markdown
import View.Page as Page



-- Model --


type alias Model =
    Page.PageModel Internals


type Internals
    = Loading
    | Ready (Post Full)
    | Failure Int


init : UUID -> General -> Page.TransformModel Internals mainModel -> Page.TransformMsg ModMsg mainMsg -> ( mainModel, Cmd mainMsg )
init uuid =
    Page.init
        Loading
        (getPost uuid)
        (Post uuid)


fromGeneral : General -> Model -> Model
fromGeneral =
    Page.fromGeneral


toGeneral : Model -> General
toGeneral =
    Page.toGeneral



-- Message --


type alias Msg =
    Page.Msg ModMsg


type ModMsg
    = GotPost (Result Http.Error (Post Full))



-- Update --


update : Msg -> Model -> ( Model, Cmd Msg )
update =
    Page.update updateMod


updateMod : ModMsg -> s -> c -> Internals -> ( Internals, Cmd ModMsg )
updateMod msg _ _ internals =
    case msg of
        GotPost _ ->
            ( internals, Cmd.none )



-- Util --


getPost : UUID -> Cmd ModMsg
getPost uuid =
    let
        path =
            UUID.toPath "/post" uuid
    in
    Http.get
        { url = Config.apiUrl ++ path
        , expect = Http.expectJson GotPost Post.fullDecoder
        }



-- View --


view : Model -> Page.ViewResult ModMsg
view model =
    Page.view model viewPost


viewPost : Session -> Cache -> Internals -> List (Html (Compound ModMsg))
viewPost session cache internals =
    let
        theme =
            Cache.theme cache
    in
    case internals of
        Loading ->
            [ text "loading" ]

        Failure err ->
            [ text "error" ]

        Ready post ->
            let
                postStyle =
                    Style.Post.style theme

                title =
                    Post.title post

                desc =
                    Post.description post

                authorUUID =
                    Post.author post

                body =
                    Post.body post

                contents =
                    Body.toString body

                authors =
                    Cache.authors cache

                username =
                    Author.usernameFromUUID authorUUID authors

                className =
                    "post"
            in
            [ div
                [ class className
                ]
                [ h1
                    [ class "title" ]
                    [ text title ]
                , h2
                    [ class "author" ]
                    [ text username ]
                , Markdown.toHtml className postStyle.content contents
                ]
            ]
