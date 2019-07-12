module Page.Post exposing (Model, Msg, fromGeneral, init, toGeneral, update, view)

import Api
import Css exposing (..)
import Browser.Navigation as Navigation
import Data.Username as Username exposing (Username)
import Data.Author as Author exposing (Author)
import Data.General as General exposing (General, Msg(..))
import Data.Markdown as Markdown exposing (Markdown)
import Data.Post as Post exposing (Client, Core, Full, Post)
import Data.Problem as Problem exposing (Description(..), Problem)
import Data.Route as Route exposing (Route(..))
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
    -- we are now ready to display an existing post
    | Ready (Post Core Full) Author
    -- page shown when failure occurs, waiting for redirect
    -- to home page
    | Redirect
    {------------------ Private States --------------------}
    -- "sneak peek" of what a post will look like
    -- referred to as "preview" in UI, but "Peek"
    -- in code to avoid conflicts
    | Peek (Post Core Full) Author
    -- the following two states are very similar, just one
    -- doesn't have info from core (such as uuid)
    | Edit (Post Core Full) Author
    | Create (Post Client Full) Author
    {------------------------------------------------------}


init : Maybe UUID -> General -> Page.TransformModel Internals mainModel -> Page.TransformMsg ModMsg mainMsg -> ( mainModel, Cmd mainMsg )
init maybePostUUID general =
    let
        maybeUserUUID =
            General.user general

        authors =
            General.authors general

        junk =
            -- TODO: Remove
            """
There was a problem here:

```
function () {
    console.log('hahahaha')
}
```

            """

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
                    case Author.fromUUID userUUID authors of
                        Just author ->
                            Page.init
                                (Create (Post.empty userUUID) author)
                                Cmd.none
                                (Post Nothing)
                                (General.pushProblem
                                    (Problem.create "Junk Problem" (MarkdownError <| Markdown.create junk
                                    ) Nothing)
                                    general
                                )

                        Nothing ->
                            Page.init
                                Redirect
                                (redirectHome general)
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

                        maybeAuthor =
                            Author.fromUUID authorUUID authors
                    in
                    case maybeAuthor of
                        Just author ->
                            { model = Ready post author
                            , general = general
                            , cmd = General.highlightBlock readyClass
                            }

                        Nothing ->
                            { model = Redirect
                            , cmd = redirectHome general
                            , general = general
                            }

                Err err ->
                    -- TODO: handle error properly (might be offline etc)
                    { model = internals
                    , cmd = redirectHome general
                    , general = general
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



redirectHome : General -> Cmd msg
redirectHome general =
    Navigation.pushUrl (General.key general) (Route.toPath Home)



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

                Redirect ->
                    [ div [ css [ flexGrow <| num 1 ] ] [] ]

                Ready post author ->
                    let
                        authors =
                            General.authors general
                    in
                    readyView general post author

                Peek post author ->
                    peekView general post

                Edit post author ->
                    editView general post

                Create post author ->
                    createView general post author
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
        |> sheet theme
        |> List.singleton


editView : General -> Post Core Full -> List (Html (Compound ModMsg))
editView general post =
    let
        theme =
            General.theme general
    in
    [  ]
        |> sheet theme
        |> List.singleton


createView : General -> Post Client Full -> Author -> List (Html (Compound ModMsg))
createView general post author =
    let
        theme =
            General.theme general
    in
    [ sheet theme
        [ heading theme
            [ authorLink author
            ]
        , input
            []
            []
        , input
            []
            []
        ]
    ]


readyView : General -> Post Core Full -> Author -> List (Html (Compound ModMsg))
readyView general post author =
    let
        theme =
            General.theme general

        postStyle =
            Style.Post.style theme

        title =
            Post.title post

        desc =
            Post.description post

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
                [ text <| Username.toString <| Author.username author ]
            , Markdown.toHtml "body" postStyle.body body
            ]
        ]
    ]


{- View Helpers -}


authorLink : Author -> Html (Compound ModMsg)
authorLink author =
    text ""


divider : Html msg
divider =
    span
        []
        [ text "/" ]


heading : Theme -> List (Html msg) -> Html msg
heading theme contents =
    div
        [ class "heading"
        , css
            [ borderRadius4 sheetRadius sheetRadius (pct 0) (pct 0)
            , displayFlex
            , Css.height <| px 50
            , backgroundColor <| Color.cardHeading theme
            ]
        ]
        contents


sheet : Theme -> List (Html msg) -> Html msg
sheet theme contents =
    div
        [ class "sheet"
        , css
            [ marginBottom <| px 50
            , marginTop <| px 50
            , backgroundColor <| Color.card theme
            , Css.width <| pct 60
            , flexGrow <| num 1
            , displayFlex
            , flexDirection column
            , borderRadius <| sheetRadius
            ]
        ]
        contents


readyClass : String
readyClass =
    "post"


sheetRadius : Px
sheetRadius =
    px 5
