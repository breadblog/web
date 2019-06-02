module Page.Post exposing (Model, Msg, fromGeneral, init, toGeneral, update, view)

import Config
import Data.Author as Author exposing (Author)
import Data.Body as Body exposing (Body)
import Data.General as General exposing (General, Msg(..))
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
import View.Page as Page exposing (PageUpdateOutput)
import Update
import Data.Problem as Problem exposing (Problem, Description(..))



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


update : Msg -> Model -> PageUpdateOutput ModMsg Internals
update =
    Page.update updateMod


updateMod : ModMsg -> General -> Internals -> Update.Output ModMsg Internals
updateMod msg general internals =
    let
        simpleOutput model =
            { model = model
            , general = general
            , cmd = Cmd.none
            }

    in
    case msg of
        GotPost res ->
            case res of
                Ok(post) ->
                    let
                        authors =
                            General.authors general

                        authorUUID =
                            Post.author post

                        maybeUsername =
                            Author.usernameFromUUID authorUUID authors
                        
                    in
                    case maybeUsername of
                        Just username ->
                            simpleOutput <| Ready post username

                        Nothing ->
                            { model = LoadingAuthors post
                            , cmd = Global <| GeneralMsg <| UpdateAuthors
                            , general = general
                            }

                Err(err) ->
                    { model = internals
                    , cmd = Cmd.none
                    , general = General.pushProblem
                        (Problem.create
                            "No Such Author"
                            HttpError err
                            Nothing
                        )
                        general
                    }



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


viewPost : General -> Internals -> List (Html (Compound ModMsg))
viewPost general internals =
    let
        theme =
            General.theme general

    in
    case internals of
        Loading ->
            loadingView theme

        Failed err ->
            failureView theme

        Ready post username ->
            let
                authors =
                    General.authors general

            in
                readyView general username post


loadingView : Theme -> List (Html (Compound ModMsg))
loadingView theme =
    []


failureView : Theme -> List (Html (Compound ModMsg)) 
failureView theme =
    []


readyView : General -> String -> Post Full -> List (Html (Compound ModMsg))
readyView general username post =
    let
        theme =
            General.theme general

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
            General.authors general

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


