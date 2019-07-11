module Page.Post exposing (Model, Msg, fromGeneral, init, toGeneral, update, view)

import Api
import Css exposing (..)
import Data.Author as Author exposing (Author)
import Data.General as General exposing (General, Msg(..))
import Data.Markdown as Markdown exposing (Markdown)
import Data.Post as Post exposing (Client, Core, Full, Post)
import Data.Problem as Problem exposing (Description(..), Problem)
import Data.Route exposing (Route(..))
import Data.Theme exposing (Theme)
import Data.UUID as UUID exposing (UUID)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events
import Http
import Message exposing (Compound(..), Msg(..))
import Style.Color as Color
import Style.Post
import Time
import Update
import View.Loading
import View.Page as Page exposing (PageUpdateOutput)



{- Model -}


type alias Model =
    Page.PageModel Internals


type Internals
    {------------------ Public States ---------------------}
    -- loading state for when we are fetching post info
    = Loading
    -- loading state when we are waiting on authors update
    | LoadingAuthors (Post Core Full)
    -- we are now ready to display an existing post
    | Ready (Post Core Full) String
    {------------------ User Only States ------------------}
    -- "sneak peek" of what a post will look like
    -- referred to as "preview" in UI, but "Peek"
    -- in code to avoid conflicts
    | Peek (Post Core Full)
    -- the following two states are very similar, just one
    -- doesn't have info from core (such as uuid)
    | Edit (Post Core Full)
    | Create (Post Client Full)
    {------------------------------------------------------}


init : Maybe UUID -> General -> Page.TransformModel Internals mainModel -> Page.TransformMsg ModMsg mainMsg -> ( mainModel, Cmd mainMsg )
init maybePostUUID general =
    let
        maybeUserUUID =
            General.user general

    in
    case maybePostUUID of
        Just postUUID ->
            Page.init
                Loading
                (getPost general postUUID)
                (Post <| Just postUUID)
                general

        Nothing ->
            case maybeUserUUID of
                Just userUUID ->
                    Page.init
                        (Create <| Post.empty userUUID)
                        Cmd.none
                        (Post Nothing)
                        general

                Nothing ->
                    let
                        problem =
                            Problem.create
                                "Not Logged In"
                                (MarkdownError <| Markdown.create "you must be logged in to create a post")
                                Nothing

                    in
                    Page.init
                        Loading
                        Cmd.none
                        (Post Nothing)
                        (General.pushProblem problem general)


fromGeneral : General -> Model -> Model
fromGeneral =
    Page.fromGeneral


toGeneral : Model -> General
toGeneral =
    Page.toGeneral



{- Message -}


type alias Msg =
    Page.Msg ModMsg


type ModMsg
    = GotPost (Result Http.Error (Post Core Full))



{- Update -}


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



{- Util -}


getPost : General -> UUID -> Cmd ModMsg
getPost general uuid =
    let
        path =
            UUID.toPath "/post/public" uuid

        mode =
            General.mode general
    in
    Api.get
        { url = Api.url mode path
        , expect = Http.expectJson GotPost Post.fullDecoder
        }



{- View -}


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

                Peek post ->
                    peekView general post

                Edit post ->
                    editView general post

                Create post ->
                    createView general post
    in
    [ div
        [ class "page post-page"
        , css
            [ displayFlex
            , flexDirection column
            , flexGrow <| num 1
            , overflowY auto
            , alignItems center
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


peekView : General -> Post Core Full -> List (Html (Compound ModMsg))
peekView general post =
    let
        theme =
            General.theme general
    in
    [  ]
        |> sheet general
        |> List.singleton


editView : General -> Post Core Full -> List (Html (Compound ModMsg))
editView general post =
    let
        theme =
            General.theme general
    in
    [  ]
        |> sheet general
        |> List.singleton


createView : General -> Post Client Full -> List (Html (Compound ModMsg))
createView general post =
    let
        theme =
            General.theme general
    in
    [  ]
        |> sheet general
        |> List.singleton


readyView : General -> String -> Post Core Full -> List (Html (Compound ModMsg))
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


{- View Helpers -}


readonlyHeader : String -> String -> Html (Compound ModMsg)
readonlyHeader username title =
    text ""


writableHeader : String -> String -> Html (Compound ModMsg)
writableHeader username title =
    div
        [ class "header edit"
        , css
            [ displayFlex
            , marginTop <| px 15
            , marginBottom <| px 15
            , alignSelf flexStart
            ]
        ]
        [ a
            [ class "author" ]
            [  ]
        ]


sheet : General -> List (Html msg) -> Html msg
sheet general contents =
    let
        theme =
            General.theme general

    in
    div
        [ class "sheet"
        , css
            [ marginBottom <| px 50
            , backgroundColor <| Color.card theme
            , Css.width <| pct 60
            , flexGrow <| num 1
            , displayFlex
            , flexDirection column
            , borderRadius <| px 7
            ]
        ]
        contents


readyClass : String
readyClass =
    "post"
