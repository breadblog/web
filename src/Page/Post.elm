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
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (onClick, onInput)
import Http
import List.Extra
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
import Page
import Debug



{- Model -}


type alias Model =
    { context : Context
    , state : State
    }


type CoreIntent
    = ToRead
    | ToPeek
    | ToEdit


type State
    = Loading (Maybe Author) (Maybe (Post Core Full)) CoreIntent
    | Read (Post Core Full) Author
    | Peek (Post Core Full) Author
    | Edit (Post Core Full) Author
    | Create (Post Client Full) Author
    | LoadingCreate
    | Delete UUID
    | Redirect



init : PostType -> Context -> ( Model, Cmd Msg )
init postType context =
    case postType of
        Route.Read uuid ->
            Debug.todo "read"

        Route.Edit uuid ->
            Debug.todo "edit"

        Route.Delete uuid ->
            Debug.todo "delete"

        Route.Create ->
            Debug.todo "create"


fromContext : Context -> Model -> Model
fromContext =
    Page.fromContext


toContext : Model -> Context
toContext =
    Page.toContext



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
    | OnAuthor (Result Http.Error (Author))
    | OnWritePost (Result Http.Error (Post Core Full))
    | OnDelete (Result Http.Error ())



{- Update -}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ context, state } as model) =
    case msg of
        Ctx contextMsg ->
            let
                (updatedContext, cmd) =
                    Context.update contextMsg context

            in
            ( { model | context = updatedContext }, Cmd.map Ctx cmd )

        OnTitleUpdate title ->
            updatePostProperty (Post.mapTitle (always title)) model

        OnDescriptionInput description ->
            updatePostProperty (Post.mapDescription (always description)) model

        OnBodyInput body ->
            updatePostProperty (Post.mapBody (always <| Markdown.create body)) model

        TogglePublished ->
            updatePostProperty (Post.mapPublished not) model

        EditCurrentPost ->
            case state of
                Read post author ->
                    if isAuthorLoggedIn context author then
                        Edit post author
                    else
                        Debug.todo "handle this"

                Peek post author ->
                    if isAuthorLoggedIn context author then
                        Edit post author
                    else
                        Debug.todo "handle this"

                _ ->
                    Debug.todo "handle this"

        DeleteCurrentPost ->
            case state of
                Read post author ->
                    goToDeleteIfLoggedIn context post author

                Edit post author ->
                    goToDeleteIfLoggedIn context post author

                Peek post author ->
                    goToDeleteIfLoggedIn context post author

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
                    if isAuthorLoggedIn context author then
                        ( model
                        , Post.post WritePostRes (Context.getMode context) post
                        )
                    else
                        Debug.todo "handle this"

                Edit post author ->
                    if isAuthorLoggedIn context author then
                        ( model
                        , Post.put WritePostRes (Context.getMode context) post
                        )
                    else
                        Debug.todo "should be a problem"

                _ ->
                    Debug.todo "handle this"

        OnPost res ->
            case res of
                Ok post ->
                    case state of
                        Loading maybeAuthor _ intent ->
                            loadIntent maybeAuthor (Just post) intent

                        _ ->
                            Debug.todo "handle this"


                Err err ->
                    Debug.todo "handle this"

        OnAuthor res ->
            case res of
                Ok author ->
                    case state of
                        Loading _ maybePost intent ->
                            loadIntent (Just author) maybePost intent

                        _ ->
                            Debug.todo "handle this"

                Err err ->
                    Debug.todo "handle this"

        OnWritePost res ->
            case res of
                Ok post ->
                    case state of
                        Edit _ author ->
                            ( { model | state = Read post author }
                            , Cmd.none
                            )

                        Create _ author ->
                            ( { model | state = Read post author }
                            , Cmd.none
                            )

                        _ ->
                            Debug.todo "handle this"

                Err err ->
                    Debug.todo "handle this"


loadIntent : Maybe Author -> Maybe (Post Core Full) -> CoreIntent -> ( Model, Cmd Msg )
loadIntent maybeAuthor maybePost intent =
    case (maybeAuthor, maybePost) of
        (Just author, Just post) ->
            case intent of
                ToRead ->
                    ( Read post author, Cmd.none )

                ToPeek ->
                    ( Peek post author, Cmd.none )

                ToEdit ->
                    ( Peek post author, Cmd.none )

        (_, _) ->
            Loading maybeAuthor maybePost intent


goToDeleteIfLoggedIn : Context -> Post Core Full -> Author -> ( Model, Cmd Msg )
goToDeleteIfLoggedIn context post author =
    if isAuthorLoggedIn context author then
        ( model
        , Navigation.pushUrl (Context.key context) (Route.toPath <| Post <| Route.Delete <| Post.uuid post)
        )
    else
        ( model, Cmd.none )


isAuthorLoggedIn : Context -> Author -> Bool
isAuthorLoggedIn context author =
    case Context.user context of
        Just user ->
            author
            |> Author.uuid
            |> UUID.compare user

        _ ->
            False


updatePostProperty : (Post l Full -> Post l Full) -> Model -> ( Model, Cmd Msg )
updatePostProperty mapPost ({ state } as model) =
    case state of
        Edit post author ->
            ( { model | state = Edit (mapPost post) author }, Cmd.none )

        Create post author ->
            ( { model | state = Create (mapPost post) author }, Cmd.none )

        _ ->
            ( model, Cmd.none )


{- Util -}



redirect404 : Context -> Cmd msg
redirect404 general =
    Navigation.pushUrl (Context.key general) (Route.toPath NotFound)



{- View -}


view : Model -> Page.ViewResult Msg
view ({ context } as model) =
    let
        theme =
            Context.theme context

        contents =
            case model of
                LoadingReady ->
                    loadingView theme

                Redirect ->
                    [ div [ css [ flexGrow <| num 1 ] ] [] ]

                Read post author ->
                    let
                        authors =
                            Context.authors context
                    in
                    readyView context post author

                Peek post author ->
                    peekView context post

                LoadingEdit ->
                    loadingView theme

                Edit post author ->
                    editView context post author

                Create post author ->
                    createView context post author

                Delete postUUID ->
                    deleteView theme postUUID
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
            Context.theme general
    in
    [ sheet theme
        []
    ]


editView : Context -> Post Core Full -> Author -> List (Html Msg)
editView general post author =
    let
        theme =
            Context.theme general
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
                [ onClick <| Ctx <|  GoBack
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
createView general post author =
    let
        theme =
            Context.theme general
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
                [ onClick <| Global <| ContextMsg <| GoBack
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
                    [ onClick <| Global <| ContextMsg GoBack
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


readyView : Context -> Post Core Full -> Author -> List (Html Msg)
readyView general post author =
    let
        theme =
            Context.theme general

        postStyle =
            Style.Post.style theme

        title =
            Post.getTitle post

        desc =
            Post.getDescription post

        body =
            Post.getBody post

        fullscreen =
            Context.fullscreen general

        myPost =
            case Context.user general of
                Nothing ->
                    False

                Just userUUID ->
                    UUID.compare (Author.uuid author) userUUID

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
            , viewTags general post
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
                general
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
            Context.theme general

        tags =
            Post.getTags post
                |> List.map (\tagUUID -> Tag.find tagUUID (Context.tags general))
                |> List.filterMap identity
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
favorite general post styles =
    let
        theme =
            Context.theme general

        maybeFav =
            case Post.favorite post of
                Just f ->
                    Just f

                Nothing ->
                    case List.Extra.find (Post.compare post) (Context.postPreviews general) of
                        Just p ->
                            Post.favorite p

                        Nothing ->
                            Nothing
    in
    case maybeFav of
        Just fav ->
            View.Svg.heart
                [ SvgEvents.onClick <| Global <| ContextMsg <| TogglePost <| Post.toPreview post
                , SvgAttributes.css
                    (List.append
                        [ svgStyle theme
                        , marginRight (px 15)
                        , fillIf fav Color.favorite
                        , color <|
                            if fav then
                                Color.favorite

                            else
                                Color.tertiaryFont <| theme
                        , hover
                            [ fillIf fav Color.favorite
                            , color Color.favorite
                            ]
                        ]
                        styles
                    )
                ]

        Nothing ->
            text ""


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
        [ SvgEvents.onClick <| Global <| ContextMsg <| FullscreenElement "post-page"
        , SvgAttributes.css
            [ svgStyle theme
            , Css.batch styles
            ]
        ]


minimize : Theme -> List Style -> Html Msg
minimize theme styles =
    View.Svg.minimize
        [ SvgEvents.onClick <| Global <| ContextMsg <| ExitFullscreen
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
        , href <| UUID.toPath "/author" (Author.uuid author)
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
        , onInput <| OnTitleInput >> Mod
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
        , onInput <| OnDescriptionInput >> Mod
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
        , onInput <| OnBodyInput >> Mod
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
