module Page.Post exposing (Model, Msg, fromContext, init, toContext, update, view)

import Api
import Browser.Navigation as Navigation
import Css exposing (..)
import Css.Transitions as Transitions exposing (transition)
import Data.Author as Author exposing (Author)
import Data.Context as Context exposing (Context, Msg(..))
import Data.Markdown as Markdown exposing (Markdown)
import Data.Post as Post exposing (Client, Core, Full, Post)
import Data.Problem as Problem exposing (Description(..))
import Data.Route as Route exposing (PostType, Route(..))
import Data.Tag as Tag exposing (Tag)
import Data.Theme exposing (Theme)
import Data.UUID as UUID exposing (UUID)
import Data.Username as Username
import Debug
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (onClick, onInput)
import Http
import List.Extra
import Page
import Style.Button
import Style.Card
import Style.Color as Color
import Style.Font as Font
import Style.Post
import Style.Screen as Screen exposing (Screen(..))
import Style.Shadow as Shadow
import Svg.Styled.Attributes as SvgAttributes
import Svg.Styled.Events as SvgEvents
import Time
import View.Loading
import View.Svg
import View.Tag



{- Model -}


type alias Model =
    { context : Context
    , state : State
    }


type CoreIntent
    = ToRead
    | ToEdit


type State
    = Loading CoreIntent
    | Read (Post Core Full)
    | Peek (Post Core Full)
    | Edit (Post Core Full)
    | Create (Post Client Full) Author
    | LoadingCreate
    | Delete UUID
    | Redirect



{- Message -}


type Msg
    = Ctx Context.Msg
    | OnTitleInput String
    | OnDescriptionInput String
    | OnBodyInput String
    | TogglePublished
    | EditCurrentPost
    | DeleteCurrentPost
    | ConfirmDelete
    | WritePost
      -- Http
    | OnPost (Result Http.Error (Post Core Full))
    | OnAuthor (Result Http.Error Author)
    | OnWritePost (Result Http.Error (Post Core Full))
    | OnDelete (Result Http.Error ())



{- Init -}


init : Context -> PostType -> ( Model, Cmd Msg )
init context postType =
    let
        withContext state =
            { context = context
            , state = state
            }
    in
    case postType of
        Route.Read uuid ->
            initCore context ToRead uuid

        Route.Edit uuid ->
            initCore context ToEdit uuid

        Route.Delete uuid ->
            ( withContext <| Delete uuid
            , Cmd.none
            )

        Route.Create ->
            case Context.getUser context of
                Just uuid ->
                    ( withContext LoadingCreate
                    , Author.fetch OnAuthor (Context.getMode context) uuid
                    )

                Nothing ->
                    ( { context = context
                      , state = Redirect
                      }
                    , Navigation.replaceUrl (Context.getKey context) (Route.toPath Route.Login)
                    )


initCore : Context -> CoreIntent -> UUID -> ( Model, Cmd Msg )
initCore context intent postUUID =
    ( { context = context
      , state = Loading intent
      }
    , fetchPost context postUUID
    )


fetchPost : Context -> UUID -> Cmd Msg
fetchPost context uuid =
    let
        mode =
            Context.getMode context
    in
    case Context.getUser context of
        Just _ ->
            Post.fetchPrivate OnPost mode uuid

        Nothing ->
            Post.fetch OnPost mode uuid


fromContext : Context -> Model -> Model
fromContext =
    Page.fromContext


toContext : Model -> Context
toContext =
    Page.toContext



{- Update -}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ context, state } as model) =
    let
        noop =
            ( model, Cmd.none )
    in
    case msg of
        Ctx contextMsg ->
            let
                ( updatedContext, cmd ) =
                    Context.update contextMsg context
            in
            ( { model | context = updatedContext }, Cmd.map Ctx cmd )

        OnTitleInput title ->
            let
                updatePost post =
                    Post.mapTitle (always title) post
            in
            case state of
                Edit post ->
                    ( { model | state = Edit (updatePost post) }, Cmd.none )

                Create post author ->
                    ( { model | state = Create (updatePost post) author }, Cmd.none )

                _ ->
                    noop

        OnDescriptionInput description ->
            let
                updatePost post =
                    Post.mapDescription (always description) post
            in
            case state of
                Edit post ->
                    ( { model | state = Edit (updatePost post) }, Cmd.none )

                Create post author ->
                    ( { model | state = Create (updatePost post) author }, Cmd.none )

                _ ->
                    noop

        OnBodyInput body ->
            let
                updatePost post =
                    Post.mapBody (Markdown.create >> always <| body) post
            in
            case state of
                Edit post ->
                    ( { model | state = Edit (updatePost post) }, Cmd.none )

                Create post author ->
                    ( { model | state = Create (updatePost post) author }, Cmd.none )

                _ ->
                    noop

        TogglePublished ->
            let
                updatePost post =
                    Post.mapPublished not post
            in
            case state of
                Edit post ->
                    ( { model | state = Edit (updatePost post) }, Cmd.none )

                Create post author ->
                    ( { model | state = Create (updatePost post) author }, Cmd.none )

                _ ->
                    noop

        EditCurrentPost ->
            let
                goToEdit post =
                    ( model
                    , post
                        |> Post.getUUID
                        |> Route.Edit
                        |> Route.Post
                        |> Route.toPath
                        |> Navigation.pushUrl (Context.getKey context)
                    )
            in
            case state of
                Read post ->
                    if isAuthor context post then
                        goToEdit post

                    else
                        Debug.todo "handle this"

                Peek post ->
                    if isAuthor context post then
                        goToEdit post

                    else
                        Debug.todo "handle this"

                _ ->
                    Debug.todo "handle this"

        DeleteCurrentPost ->
            case state of
                Read post ->
                    goToDeleteIfLoggedIn model post

                Edit post ->
                    goToDeleteIfLoggedIn model post

                Peek post ->
                    goToDeleteIfLoggedIn model post

                _ ->
                    Debug.todo "handle this"

        ConfirmDelete ->
            case state of
                Delete postUUID ->
                    ( model
                    , Post.delete OnDelete (Context.getMode context) postUUID
                    )

                _ ->
                    Debug.todo "handle this"

        WritePost ->
            case state of
                Create post author ->
                    if isAuthor context post then
                        ( model
                        , Post.put OnWritePost (Context.getMode context) post
                        )

                    else
                        Debug.todo "handle this"

                Edit post ->
                    if isAuthor context post then
                        ( model
                        , Post.edit OnWritePost (Context.getMode context) post
                        )

                    else
                        Debug.todo "should be a problem"

                _ ->
                    noop

        OnPost res ->
            case res of
                Ok post ->
                    case state of
                        Loading intent ->
                            case intent of
                                ToRead ->
                                    ( { model | state = Read post }, Cmd.none )

                                ToEdit ->
                                    ( { model | state = Edit post }, Cmd.none )

                        _ ->
                            noop

                Err err ->
                    Debug.todo "handle this"

        OnAuthor res ->
            case res of
                Ok author ->
                    case state of
                        LoadingCreate ->
                            ( { model | state = Create (Post.empty author) author }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                Err err ->
                    Debug.todo "handle this"

        OnWritePost res ->
            case res of
                Ok post ->
                    let
                        goToRead =
                            ( model
                            , post
                                |> Post.getUUID
                                |> Route.Read
                                |> Route.Post
                                |> Route.toPath
                                |> Navigation.replaceUrl (Context.getKey context)
                            )
                    in
                    case state of
                        Edit _ ->
                            goToRead

                        Create _ _ ->
                            goToRead

                        _ ->
                            noop

                Err err ->
                    Debug.todo "handle this"

        OnDelete res ->
            case res of
                Ok _ ->
                    ( model
                    , Navigation.pushUrl (Context.getKey context) (Route.toPath Home)
                    )

                Err err ->
                    Debug.todo "handle me"


goToDeleteIfLoggedIn : Model -> Post Core Full -> ( Model, Cmd Msg )
goToDeleteIfLoggedIn ({ context } as model) post =
    if isAuthor context post then
        ( model
        , Navigation.pushUrl (Context.getKey context) (Route.toPath <| Post <| Route.Delete <| Post.getUUID post)
        )

    else
        ( model, Cmd.none )


isAuthor : Context -> Post l b -> Bool
isAuthor context post =
    case Context.getUser context of
        Just user ->
            post
                |> Post.getAuthor
                |> Author.getUUID
                |> UUID.compare user

        _ ->
            False



{- Util -}


redirect404 : Context -> Cmd msg
redirect404 general =
    Navigation.pushUrl (Context.getKey general) (Route.toPath NotFound)



{- View -}


view : Model -> List (Html Msg)
view ({ context, state } as model) =
    let
        theme =
            Context.getTheme context

        contents =
            case state of
                Loading _ ->
                    loadingView theme

                LoadingCreate ->
                    loadingView theme

                Read post ->
                    readView context post

                Peek post ->
                    peekView context post

                Edit post ->
                    editView context post

                Create post author ->
                    createView context post author

                Delete postUUID ->
                    deleteView theme postUUID

                Redirect ->
                    [ div [ css [ flexGrow <| num 1 ] ] [] ]
    in
    [ div
        [ class "page post-page"
        , css
            [ displayFlex
            , flexDirection column
            , flexGrow <| num 1
            , overflowY auto
            , alignItems center
            , position relative
            ]
        ]
        contents
    ]



-- TODO: don't flicker


loadingView : Theme -> List (Html Msg)
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


peekView : Context -> Post Core Full -> List (Html Msg)
peekView general post =
    let
        theme =
            Context.getTheme general
    in
    [ sheet theme
        []
    ]


editView : Context -> Post Core Full -> List (Html Msg)
editView general post =
    let
        theme =
            Context.getTheme general

        author =
            Post.getAuthor post
    in
    [ sheet theme
        [ div
            [ css
                [ Style.Card.headingStyle theme ]
            ]
            [ authorLink author theme
            , divider theme
            , titleInput theme <| Post.getTitle post
            , filler
            , togglePublished theme post [ marginRight <| px 15 ]
            ]
        , h3
            [ css
                [ textAreaLabelStyle
                , margin4 (px 10) (px 0) (px 0) (px 15)
                ]
            ]
            [ text "Description" ]
        , descInput theme <| Post.getDescription post
        , h3
            [ css
                [ textAreaLabelStyle
                , margin4 (px 0) (px 0) (px 0) (px 15)
                ]
            ]
            [ text "Body" ]
        , bodyInput theme <| Post.getBody post
        , div
            [ css [ displayFlex ]
            ]
            [ button
                [ onClick <| Ctx <| GoBack
                , css
                    [ Style.Button.default
                    , Style.Button.danger theme
                    , margin4 (px 0) (px 10) (px 10) (px 10)
                    , flex3 (num 1) (num 0) (num 0)
                    ]
                ]
                [ text "Back" ]
            , button
                [ css
                    [ Style.Button.default
                    , Style.Button.submit
                    , margin4 (px 0) (px 10) (px 10) (px 10)
                    , flex3 (num 1) (num 0) (num 0)
                    ]
                , onClick WritePost
                ]
                [ text "Edit" ]
            ]
        ]
    ]


createView : Context -> Post Client Full -> Author -> List (Html Msg)
createView context post author =
    let
        theme =
            Context.getTheme context
    in
    [ sheet theme
        [ div
            [ css
                [ Style.Card.headingStyle theme
                ]
            ]
            [ authorLink author theme
            , divider theme
            , titleInput theme <| Post.getTitle post
            , filler
            , togglePublished theme post [ marginRight <| px 15 ]
            ]
        , h3
            [ css
                [ textAreaLabelStyle
                , margin4 (px 10) (px 0) (px 0) (px 15)
                ]
            ]
            [ text "Description" ]
        , descInput theme <| Post.getDescription post
        , h3
            [ css
                [ textAreaLabelStyle
                , margin4 (px 0) (px 0) (px 0) (px 15)
                ]
            ]
            [ text "Body" ]
        , bodyInput theme <| Post.getBody post
        , div
            [ css
                [ displayFlex ]
            ]
            [ button
                [ onClick <| Ctx <| GoBack
                , css
                    [ Style.Button.default
                    , Style.Button.danger theme
                    , margin4 (px 0) (px 10) (px 10) (px 10)
                    , flex3 (num 1) (num 0) (num 0)
                    ]
                ]
                [ text "Back" ]
            , button
                [ css
                    [ Style.Button.default
                    , Style.Button.submit
                    , margin4 (px 0) (px 10) (px 10) (px 10)
                    , flex3 (num 1) (num 0) (num 0)
                    ]
                , onClick WritePost
                ]
                [ text "Create" ]
            ]
        ]
    ]


deleteView : Theme -> UUID -> List (Html Msg)
deleteView theme postUUID =
    [ div
        [ class "delete-post"
        , css
            [ displayFlex
            , justifyContent center
            , alignItems center
            , Css.height <| pct 100
            , Css.width <| pct 100
            ]
        ]
        [ div
            [ css
                [ Css.width <| pct 20
                , Shadow.dp4
                , Style.Card.style theme
                ]
            ]
            [ div
                [ css
                    [ Style.Card.headingStyle theme ]
                ]
                [ h1
                    [ css
                        [ fontWeight <| int 400
                        , fontSize <| rem 1.3
                        , margin2 (px 0) auto
                        , color <| Color.primaryFont theme
                        ]
                    ]
                    [ text "Confirm post deletion?"
                    ]
                ]
            , p
                [ css
                    [ margin2 (px 15) (px 15)
                    , color <| Color.secondaryFont theme
                    ]
                ]
                [ text "Deleting a post is a permanent action. Please ensure you no longer want access to this post before deletion." ]
            , div
                [ class "buttons"
                , css
                    [ Css.width <| pct 100
                    , displayFlex
                    , justifyContent center
                    , marginBottom <| px 10
                    ]
                ]
                [ button
                    [ onClick <| Ctx <| GoBack
                    , css
                        [ Style.Button.default
                        , backgroundColor <| Color.danger theme
                        , marginRight <| px 15
                        ]
                    ]
                    [ text "Go Back" ]
                , button
                    [ onClick ConfirmDelete
                    , css
                        [ Style.Button.default
                        , Style.Button.submit
                        ]
                    ]
                    [ text "Submit" ]
                ]
            ]
        ]
    ]


readView : Context -> Post Core Full -> List (Html Msg)
readView context post =
    let
        theme =
            Context.getTheme context

        postStyle =
            Style.Post.style theme

        title =
            Post.getTitle post

        desc =
            Post.getDescription post

        body =
            Post.getBody post

        author =
            Post.getAuthor post

        fullscreen =
            Context.getFullscreen context

        myPost =
            case Context.getUser context of
                Nothing ->
                    False

                Just userUUID ->
                    UUID.compare (Author.getUUID author) userUUID

        -- fav =
    in
    [ sheet theme
        [ div
            [ css
                [ Style.Card.headingStyle theme ]
            ]
            [ authorLink author theme
            , divider theme
            , viewTitle theme title
            , viewTags context post
            , filler
            , if myPost then
                delete theme []

              else
                text ""
            , if myPost then
                edit theme []

              else
                text ""
            , if fullscreen then
                minimize theme []

              else
                maximize theme []
            , favorite
                context
                post
                []
            ]
        , Markdown.toHtml
            markdownClass
            [ padding (px 15)
            , overflowY auto
            ]
            postStyle
            body
        ]
    ]



{- View Helpers -}


viewTags : Context -> Post l f -> Html msg
viewTags general post =
    let
        theme =
            Context.getTheme general

        tags =
            Post.getTags post
    in
    div
        [ class "tags-container"
        , css
            [ displayFlex
            ]
        ]
        (List.map
            (\t -> View.Tag.view theme [] t)
            tags
        )


edit : Theme -> List Style -> Html Msg
edit theme styles =
    View.Svg.edit
        [ SvgEvents.onClick EditCurrentPost
        , SvgAttributes.css
            [ svgStyle theme
            , Css.batch styles
            ]
        ]


delete : Theme -> List Style -> Html Msg
delete theme styles =
    View.Svg.trash2
        [ SvgEvents.onClick DeleteCurrentPost
        , SvgAttributes.css
            [ svgStyle theme
            , Css.batch styles
            ]
        ]


favorite : Context -> Post Core f -> List Style -> Html Msg
favorite context post styles =
    let
        theme =
            Context.getTheme context

        isLiked =
            Context.isPostLiked context post
    in
    View.Svg.heart
        [ SvgEvents.onClick <| Ctx <| TogglePost <| Post.getUUID post
        , SvgAttributes.css
            (List.append
                [ svgStyle theme
                , marginRight (px 15)
                , fillIf isLiked Color.favorite
                , color <|
                    if isLiked then
                        Color.favorite

                    else
                        Color.tertiaryFont <| theme
                , hover
                    [ fillIf isLiked Color.favorite
                    , color Color.favorite
                    ]
                ]
                styles
            )
        ]


fillIf : Bool -> Color -> Style
fillIf bool color =
    Css.batch <|
        if bool then
            [ Css.fill color ]

        else
            []


togglePublished : Theme -> Post l f -> List Style -> Html Msg
togglePublished theme post styles =
    let
        published =
            Post.getPublished post

        svg =
            if published then
                View.Svg.unlock

            else
                View.Svg.lock
    in
    svg
        [ SvgEvents.onClick TogglePublished
        , SvgAttributes.css
            [ svgStyle theme
            , Css.batch styles
            ]
        ]


maximize : Theme -> List Style -> Html Msg
maximize theme styles =
    View.Svg.maximize
        [ SvgEvents.onClick <| Ctx <| FullscreenElement "post-page"
        , SvgAttributes.css
            [ svgStyle theme
            , Css.batch styles
            ]
        ]


minimize : Theme -> List Style -> Html Msg
minimize theme styles =
    View.Svg.minimize
        [ SvgEvents.onClick <| Ctx <| ExitFullscreen
        , SvgAttributes.css
            [ svgStyle theme
            , Css.batch styles
            ]
        ]


svgStyle : Theme -> Style
svgStyle theme =
    Css.batch
        [ margin2 (px 0) (px 7)
        , cursor pointer
        , color <| Color.tertiaryFont theme
        , Css.property "flex" "0 0 auto"
        , hover
            [ color <| Color.secondaryFont theme
            ]
        , transition
            [ Transitions.color3 100 0 Transitions.easeInOut ]
        , Screen.style Screen.mobile
            [ Css.width (px 22)
            , Css.height (px 22)
            ]
        ]


filler : Html msg
filler =
    div
        [ class "filler"
        , css
            [ displayFlex
            , flex3 (int 1) (int 0) (int 0)
            ]
        ]
        []


authorLink : Author -> Theme -> Html Msg
authorLink author theme =
    a
        [ class "author"
        , href <| UUID.toPath "/author" (Author.getUUID author)
        , css
            [ textDecoration none
            , marginLeft <| px 15
            , fontWeight <| int 500
            , fontSize <| rem 1
            , color <| Color.secondaryFont theme
            , whiteSpace noWrap
            , Screen.style Screen.mobile
                [ textOverflow ellipsis
                ]
            ]
        ]
        [ text <| Username.toString <| Author.username author ]


viewTitle : Theme -> String -> Html msg
viewTitle theme title =
    h1
        [ class "title"
        , css
            [ fontSize <| rem 1.2
            , margin4 (px 0) (px 20) (px 2) (px 3)
            , whiteSpace noWrap
            , textOverflow ellipsis
            , Css.property "flex" "0 1 auto"
            , overflow Css.hidden
            ]
        ]
        [ text title ]


titleInput : Theme -> String -> Html Msg
titleInput theme title =
    input
        [ class "title-input"
        , value title
        , onInput <| OnTitleInput
        , autofocus True
        , css
            [ inputStyle theme
            , fontWeight <| int 600
            , marginLeft <| px 2
            , borderColor <| Color.cardHeading theme
            , Screen.style Screen.mobile
                [ flex3 (int 1) (int 1) (px 200)
                , minWidth (px 0)
                ]
            ]
        ]
        []


descInput : Theme -> String -> Html Msg
descInput theme desc =
    textarea
        [ class "desc-input"
        , value desc
        , onInput <| OnDescriptionInput
        , css
            [ inputStyle theme
            , fontWeight <| int 500
            , borderColor <| Color.card theme
            , flex3 (int 1) (int 0) (px 0)
            , margin (px 10)
            , resize none
            ]
        ]
        []


bodyInput : Theme -> Markdown -> Html Msg
bodyInput theme body =
    textarea
        [ class "desc-input"
        , Markdown.toValue body
        , onInput OnBodyInput
        , css
            [ inputStyle theme
            , fontWeight <| int 500
            , borderColor <| Color.card theme
            , flex3 (int 5) (int 0) (px 0)
            , margin (px 10)
            , resize none
            ]
        ]
        []


inputStyle : Theme -> Style
inputStyle theme =
    Css.batch
        [ borderWidth <| px 2
        , borderStyle solid
        , fontFamilies Font.montserrat
        , backgroundColor <| Color.accent theme
        , color <| Color.secondaryFont theme
        , borderRadius <| px 6
        , padding2 (px 3) (px 5)
        , outline none
        , focus
            [ borderColor <| Color.secondary theme
            ]
        , transition
            [ Transitions.borderColor3 100 0 Transitions.easeIn ]
        ]


divider : Theme -> Html msg
divider theme =
    span
        [ css
            [ fontSize <| rem 1
            , fontFamilies Font.montserrat
            , color <| Color.secondaryFont theme
            , fontWeight <| int 600
            , margin2 (px 0) (px 4)
            ]
        ]
        [ text "/" ]


sheet : Theme -> List (Html msg) -> Html msg
sheet theme contents =
    div
        [ class "sheet post-sheet"
        , css
            [ marginBottom <| px 50
            , marginTop <| px 50
            , Css.width <| pct 60
            , flexGrow <| num 1
            , displayFlex
            , flexDirection column
            , Style.Card.style theme
            , Screen.style Screen.mobile
                [ Css.width (pct 95)
                , marginTop (px 25)
                , marginBottom (px 25)
                ]
            ]
        ]
        contents


markdownClass : String
markdownClass =
    "post-md"


textAreaLabelStyle : Style
textAreaLabelStyle =
    Css.batch
        []
