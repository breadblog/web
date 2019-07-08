module Page.Post exposing (Model, Msg, fromGeneral, init, toGeneral, update, view)

import Api
import Data.Author as Author exposing (Author)
import Data.General as General exposing (General, Msg(..))
import Data.Markdown as Markdown exposing (Markdown)
import Data.Post as Post exposing (Full, Post)
import Data.Problem as Problem exposing (Description(..), Problem)
import Data.Route exposing (Route(..))
import Data.Theme exposing (Theme)
import Data.UUID as UUID exposing (UUID)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events
import Css exposing (..)
import Http
import Message exposing (Compound(..), Msg(..))
import Style.Post
import Time
import Update
import View.Page as Page exposing (PageUpdateOutput)
import View.Loading
import Style.Color as Color



-- Model --


type alias Model =
    Page.PageModel Internals


type Internals
    = Loading
    | LoadingAuthors (Post Full)
    | Ready (Post Full) String


type Failure
    = NoSuchAuthor UUID


init : UUID -> General -> Page.TransformModel Internals mainModel -> Page.TransformMsg ModMsg mainMsg -> ( mainModel, Cmd mainMsg )
init uuid general =
    Page.init
        Loading
        (getPost general uuid)
        (Post uuid)
        general


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
                Ok post ->
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
                            { model = Ready post username
                            , general = general
                            , cmd = General.highlightBlock readyClass
                            }

                        Nothing ->
                            { model = LoadingAuthors post
                            , cmd =
                                Cmd.map
                                    (\c -> Global <| GeneralMsg <| c)
                                    (General.updateAuthors general)
                            , general = general
                            }

                Err err ->
                    { model = internals
                    , cmd = Cmd.none
                    , general =
                        General.pushProblem
                            (Problem.create
                                "No Such Author"
                                (HttpError err)
                                Nothing
                            )
                            general
                    }



-- Util --


getPost : General -> UUID -> Cmd ModMsg
getPost general uuid =
    let
        path =
            UUID.toPath "/post/public" uuid

        host =
            General.host general
    in
    Api.get
        { url = Api.url host path
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

        contents =
            case internals of
                Loading ->
                    loadingView theme

                LoadingAuthors _ ->
                    loadingView theme

                Ready post username ->
                    let
                        authors =
                            General.authors general
                    in
                    readyView general username post

    in
        [ div
            [ css
                [ displayFlex
                , flexDirection column
                , flexGrow <| num 1
                ]
            ]
            contents
        ]


loadingView : Theme -> List (Html (Compound ModMsg))
loadingView theme =
    [ div
        [ css
            [ displayFlex
            , justifyContent center
            , alignItems center
            , Css.height <| pct 100
            , Css.width <| pct 100
            ]
        ]
        [ View.Loading.toHtml
            { timing = 3
            , size = 1.5
            }
        ]
    ]


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

        authors =
            General.authors general

        body =
            Post.body post
    in
    [ div
        [ classList
            [ ( readyClass, True )
            , ( "animated", True )
            , ( "fadeIn", True )
            ]
        , css
            [ Css.height <| pct 100
            , Css.width <| pct 100
            , displayFlex
            , justifyContent center
            , alignItems center
            , flexDirection column
            ]
        ]
        [ div
            [ class "card"
            , css
                [ marginTop <| px 50
                , marginBottom <| px 50
                , backgroundColor <| Color.card theme
                , maxWidth <| pct 60
                , flexGrow <| num 1
                ]
            ]
            [ h1
                [ class "title" ]
                [ text title ]
            , h2
                [ class "author" ]
                [ text username ]
            , Markdown.toHtml "body" postStyle.body body
            ]
        ]
    ]


readyClass : String
readyClass =
    "post"
