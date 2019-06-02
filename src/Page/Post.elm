module Page.Post exposing (Model, Msg, fromGeneral, init, toGeneral, update, view)

import Config
import Data.Author as Author exposing (Author)
import Data.Body as Body exposing (Body)
import Data.General as General exposing (General)
import Data.Post as Post exposing (Full, Post)
import Data.Route exposing (Route(..))
import Data.Theme exposing (Theme)
import Data.UUID as UUID exposing (UUID)
import Data.Markdown as Markdown exposing (Markdown)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events
import Http
import Message exposing (Compound(..), Msg(..))
import Style.Post
import Time
import View.Page as Page



-- Model --


type alias Model =
    Page.PageModel Internals


type Internals
    = Loading
    | LoadingAuthors (Post Full)
    | Ready (Post Full) String
    | Failed Failure


type Failure
    = NoSuchAuthor UUID



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


updateMod : ModMsg -> Session -> Cache -> Internals -> ( Internals, Cmd ModMsg )
updateMod msg _ cache internals =
    case msg of
        GotPost post ->
            let
                authors =
                    Cache.authors cache

                maybeUsername =
                    Author.usernameFromUUID authorUUID authors
                
            in
            case maybeUsername of
                Just username ->
                    Ready post username

                Nothing ->
                    (LoadingAuthors post, )



            case internals of
                LoadingAuthors ->
                    case maybeUsername of
                        Just username ->
                            ( Ready post username )

                _ ->
                    case maybeUsername of
                        Just username ->
                            ( Ready post username, Cmd.none )

                        Nothing ->
                            ( LoadingAuthor post, Cmd.none )





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
            loadingView theme

        Failure err ->
            failureView theme

        Ready post ->
            let
                authors =
                    Cache.authors cache

                maybeUsername =
                    Author.usernameFromUUID authorUUID authors
                    
            in
            case maybeUsername of
                Just username ->

                Nothing ->



loadingView : Theme -> List (Html (Compound ModMsg))
loadingView theme =
    []


failureView : Theme -> List (Html (Compound ModMsg)) 
failureView theme =
    []


readyView : Session -> Cache -> Internals -> List (Html (Compound ModMsg))
readyView session cache internals =
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

        maybeUsername =

        className =
            "post"
    in
    case maybeUsername of
        Just username ->

        Nothing ->
            -- unable to find matching username, should trigger refresh of 
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


