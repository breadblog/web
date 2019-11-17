module Page.Post exposing (Model, Msg, init, mapGeneral, toGeneral, update, view)

import Api
import Css exposing (..)
import Css.Transitions as Transitions exposing (transition)
import Data.Author as Author exposing (Author)
import Data.General as General exposing (General, Msg(..))
import Data.Markdown as Markdown exposing (Markdown)
import Data.Post as Post exposing (Client, Core, Full, Post)
import Data.Problem as Problem exposing (Description(..), Problem)
import Data.Route as Route exposing (PostRoute(..), Route(..))
import Data.Tag as Tag exposing (Tag)
import Data.Theme as Theme exposing (Theme)
import Data.UUID as UUID exposing (UUID)
import Data.Username as Username exposing (Username)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events as Events
import Http
import List.Extra
import Style.Button
import Style.Card
import Style.Color as Color
import Style.Font as Font
import Style.Post
import Style.Screen as Screen
import Style.Shadow as Shadow
import Svg.Styled.Attributes as SvgAttributes
import Svg.Styled.Events as SvgEvents
import View.Footer as Footer
import View.Header as Header
import View.Loading
import View.Svg
import View.Tag



{- Model -}


type Model
    = Model Internals


type alias Internals =
    { header : Header.Model
    , general : General
    , page : Page
    }


type
    Page
    {------------------ Public States ---------------------}
    -- loading state for when we are fetching post info
    = LoadingRead
      -- we are now ready to display an existing post
    | Read (Post Core Full) Author
    | Redirect
      {------------------ Private States --------------------}
      -- "sneak peek" of what a post will look like
      -- referred to as "preview" in UI, but "Peek"
      -- in code to avoid conflicts
    | Peek (Post Core Full) Author
    | LoadingEdit
    | Edit (Post Core Full) Author
    | Create (Post Client Full) Author
    | LoadingDelete
    | Delete (Post Core Full) Author
    | NotLoggedIn


init : General -> PostRoute -> ( Model, Cmd Msg )
init general postRoute =
    let
        route =
            General.route general

        mode =
            General.mode general

        header =
            Header.init
    in
    case postRoute of
        Route.Create ->
            let
                maybeAuthor =
                    General.user general
                        |> Maybe.andThen
                            (\uuid -> Author.fromUUID uuid (General.authors general))
            in
            case maybeAuthor of
                Just author ->
                    ( Model
                        { general = general
                        , header = header
                        , page = Create (Post.empty (Author.uuid author)) author 0
                        }
                    , Cmd.none
                    )

                Nothing ->
                    ( Model
                        { general = general
                        , header = header
                        , page = NotLoggedIn
                        }
                    , Cmd.map GeneralMsg <| General.logout general
                    )

        Route.Read postUUID ->
            ( Model
                { general = general
                , header = header
                , page = LoadingRead
                }
            , Api.getPost
                { mode = General.mode general
                , user = General.user general
                , uuid = postUUID
                , msg = GotPost
                }
            )

        Route.Edit postUUID ->
            case General.user general of
                Just userUUID ->
                    ( Model
                        { general = general
                        , header = header
                        , page = LoadingEdit
                        }
                    , Api.getPost
                        { mode = General.mode general
                        , user = General.user general
                        , uuid = postUUID
                        , msg = GotPost
                        }
                    )

                Nothing ->
                    ( Model
                        { general = general
                        , header = header
                        , page = NotLoggedIn
                        }
                    , Cmd.none
                    )

        Route.Delete postUUID ->
            case General.user general of
                Just userUUID ->
                    ( Model
                        { general = general
                        , header = header
                        , page = LoadingDelete
                        }
                    , Api.getPost
                        { mode = General.mode general
                        , user = General.user general
                        , uuid = postUUID
                        , msg = GotPost
                        }
                    )

                Nothing ->
                    ( Model
                        { general = general
                        , header = header
                        , page = NotLoggedIn
                        }
                    , Cmd.none
                    )


toGeneral : Model -> General
toGeneral (Model internals) =
    internals.general


mapGeneral : (General -> General) -> Model -> Model
mapGeneral transform (Model internals) =
    Model { internals | general = transform internals.general }



{- Message -}


type Msg
    = GeneralMsg General.Msg
    | HeaderMsg Header.Msg
    | GotPost (Result Http.Error (Post Core Full))
    | OnTitleInput String
    | OnDescriptionInput String
    | OnBodyInput String
    | Write
    | GotWrite (Result Http.Error (Post Core Full))
    | EditCurrentPost
    | DeleteCurrentPost
    | ConfirmDelete
    | GotDelete (Result Http.Error ())
    | TogglePublished
    | ToggleFavorite



-- TODO: when we write to post, should update General previews
{- Update -}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        (Model internals) =
            model

        general =
            internals.general

        page =
            internals.page
    in
    case msg of
        GeneralMsg generalMsg ->
            General.update generalMsg general
                |> Tuple.mapFirst (\updatedGeneral -> Model { internals | general = updatedGeneral })
                |> Tuple.mapSecond (Cmd.map GeneralMsg)

        GotPost res ->
            gotPost model res

        OnTitleInput str ->
            case page of
                Create post author ->
                    let
                        updatedPost =
                            str
                                |> String.left 64
                                |> always
                                |> (\m -> Post.mapTitle m post)
                    in
                    ( Model { internals | page = Create updatedPost author }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        OnDescriptionInput str ->
            case page of
                Create post author ->
                    let
                        updatedPost =
                            str
                                |> String.left 256
                                |> always
                                |> (\m -> Post.mapTitle m post)
                    in
                    ( Model { internals | page = Create updatedPost author }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        OnBodyInput str ->
            case page of
                Create post author ->
                    let
                        updatedPost =
                            str
                                |> String.left 100000
                                |> Markdown.create
                                |> always
                                |> (\m -> Post.mapBody m post)
                    in
                    ( Model
                        general
                        (Create updatedPost author attempts)
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        Write ->
            case page of
                Create post author _ ->
                    ( model
                    , Api.createPost
                        { msg = GotWrite
                        , resource = post
                        , user = General.user general
                        , mode = General.mode general
                        }
                    )

                Edit post author _ ->
                    ( model
                    , Api.updatePost
                        { msg = GotWrite
                        , resource = post
                        , user = General.user general
                        , mode = General.mode general
                        }
                    )

                _ ->
                    ( model, Cmd.none )

        GotWrite res ->
            case res of
                Ok post ->
                    case page of
                        Create _ author _ ->
                            ( Model
                                general
                                (Read post author)
                            , Cmd.none
                            )

                        Edit _ author _ ->
                            ( Model
                                general
                                (Read post author)
                            , Cmd.none
                            )

                        _ ->
                            ( model, Cmd.none )

                Err writeErr ->
                    let
                        createProblem err =
                            Problem.create
                                "Failed to write post"
                                (HttpError err)
                                Nothing
                    in
                    case page of
                        Create post author attempts ->
                            ( Model
                                (General.pushProblem (createProblem writeErr) general)
                                (Create post author 0)
                            , Cmd.none
                            )

                        Edit post author attempts ->
                            ( Model
                                (General.pushProblem (createProblem writeErr) general)
                                (Edit post author 0)
                            , Cmd.none
                            )

                        _ ->
                            ( model, Cmd.none )

        EditCurrentPost ->
            case page of
                Read post author ->
                    ( Model
                        general
                        (Edit post author 0)
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        DeleteCurrentPost ->
            case General.user general of
                Just userUUID ->
                    let
                        unauthorizedProblem =
                            Problem.create
                                "Cannot delete post"
                                (MarkdownError <| Markdown.create "Only the author can delete a post")
                                Nothing

                        isAuthor post =
                            General.user general
                                |> Maybe.map (UUID.compare <| Post.author post)
                                |> Maybe.withDefault False
                    in
                    case page of
                        Read post author ->
                            if isAuthor post then
                                ( Model
                                    general
                                    (Delete post author 0)
                                , Cmd.none
                                )

                            else
                                ( Model
                                    (General.pushProblem unauthorizedProblem general)
                                    internals
                                , Cmd.none
                                )

                        Edit post author attempts ->
                            if isAuthor post then
                                ( Model
                                    general
                                    (Delete post author 0)
                                , Cmd.none
                                )

                            else
                                ( Model
                                    (General.pushProblem unauthorizedProblem general)
                                    internals
                                , Cmd.none
                                )

                        _ ->
                            ( model, Cmd.none )

                Nothing ->
                    let
                        problem =
                            Problem.create
                                "Not Logged In"
                                (MarkdownError <| Markdown.create "Only the author can delete a post")
                                Nothing
                    in
                    ( Model
                        (General.pushProblem problem general)
                        internals
                    , Cmd.none
                    )

        ConfirmDelete ->
            case page of
                Delete post _ _ ->
                    ( model
                    , Api.deletePost
                        { msg = GotDelete
                        , uuid = Post.uuid post
                        , mode = General.mode general
                        , user = General.user general
                        }
                    )

                _ ->
                    ( model, Cmd.none )

        GotDelete res ->
            case res of
                Ok _ ->
                    ( Model general Redirect
                    , General.pushUrl general (Route.toPath Home)
                    )

                Err err ->
                    let
                        problem =
                            Problem.create "Failed to delete post" (HttpError err) Nothing
                    in
                    ( Model (General.pushProblem problem general) internals
                    , Cmd.none
                    )

        TogglePublished ->
            case page of
                Edit post author attempts ->
                    ( Model
                        general
                        (Edit (Post.mapPublished not post) author attempts)
                    , Cmd.none
                    )

                Create post author attempts ->
                    ( Model
                        general
                        (Create (Post.mapPublished not post) author attempts)
                    , Cmd.none
                    )

                _ ->
                    ( model
                    , Cmd.none
                    )

        ToggleFavorite ->
            case page of
                Edit post author attempts ->
                    ( Model
                        general
                        (Edit (Post.mapFavorite not post) author attempts)
                    , Cmd.none
                    )

                Create post author attempts ->
                    -- favorites are not an edit thing
                    ( Model
                        general
                        (Create (Post.mapFavorite not post) author attempts)
                    , Cmd.none
                    )

                _ ->
                    ( model
                    , Cmd.none
                    )


gotPost : Model -> Result Http.Error (Post Core Full) -> ( Model, Cmd Msg )
gotPost model res =
    let
        (Model general internals) =
            model
    in
    case res of
        Ok post ->
            let
                authors =
                    General.authors general

                authorUUID =
                    Post.author post

                maybeAuthor =
                    Author.fromUUID authorUUID authors

                userIsAuthor =
                    maybeAuthor
                        |> Maybe.map Author.uuid
                        |> Maybe.map2 UUID.compare (General.user general)
                        |> Maybe.withDefault False
            in
            case maybeAuthor of
                Just author ->
                    case page of
                        LoadingRead ->
                            ( Model general (Read post author)
                            , Cmd.none
                            )

                        LoadingDelete ->
                            if userIsAuthor then
                                ( Model general (Delete post author 0)
                                , Cmd.none
                                )

                            else
                                let
                                    handler =
                                        Problem.createHandler
                                            "View Post"
                                            (NavigateTo <| Route.Post <| Route.Read <| Post.uuid post)

                                    problem =
                                        Problem.create
                                            "Cannot delete post"
                                            (MarkdownError <| Markdown.create "Only author can remove post")
                                            (Just handler)
                                in
                                ( Model
                                    (General.pushProblem problem general)
                                    LoadingRead
                                , Cmd.none
                                )

                        LoadingEdit ->
                            if userIsAuthor then
                                ( Model general (Edit post author 0)
                                , Cmd.none
                                )

                            else
                                let
                                    handlerMsg =
                                        NavigateTo <| Route.Post <| Route.Read <| Post.uuid post

                                    handler =
                                        Problem.createHandler "View Post" handlerMsg

                                    md =
                                        Markdown.create "Only author can remove post"

                                    problem =
                                        Problem.create "Cannot edit post" (MarkdownError md) (Just handler)

                                    updatedGeneral =
                                        General.pushProblem problem general
                                in
                                ( Model updatedGeneral LoadingRead
                                , Cmd.none
                                )

                        _ ->
                            ( model, Cmd.none )

                Nothing ->
                    let
                        handlerMsg =
                            NavigateTo Home

                        handler =
                            Problem.createHandler "Go Home" handlerMsg

                        problem =
                            Problem.create
                                "Post Author Missing"
                                (MarkdownError <| Markdown.create "Cannot find author for the post you were trying to look at")
                                (Just handler)

                        updatedGeneral =
                            General.pushProblem problem general
                    in
                    ( Model updatedGeneral internals
                    , Cmd.none
                    )

        Err err ->
            let
                routeMsg =
                    NavigateTo (General.route general)

                handler =
                    Problem.createHandler "Try Again" routeMsg

                problem =
                    Problem.create "Failed to get post" (HttpError err) (Just handler)

                updatedGeneral =
                    General.pushProblem problem general
            in
            ( Model updatedGeneral internals
            , Cmd.none
            )



{- Util -}


redirect404 : General -> Cmd msg
redirect404 general =
    General.pushUrl general (Route.toPath NotFound)



{- View -}


view : Model -> List (Html Msg)
view (Model internals) =
    List.concat
        [ List.map (Html.Styled.map HeaderMsg) (Header.view internals.general internals.header)
        , viewPost internals
        , Footer.view (General.theme internals.general) (General.version internals.general)
        ]


viewPost : Model -> List (Html Msg)
viewPost (Model internals) =
    let
        general =
            internals.general

        page =
            internals.page

        theme =
            General.theme general

        contents =
            case page of
                LoadingRead ->
                    loadingView theme

                LoadingEdit ->
                    loadingView theme

                LoadingDelete ->
                    loadingView theme

                NotLoggedIn ->
                    notLoggedInView theme

                Redirect ->
                    [ div [ css [ flexGrow <| num 1 ] ] [] ]

                Read post author ->
                    let
                        authors =
                            General.authors general
                    in
                    readyView general post author

                Peek post author ->
                    peekView general post

                Edit post author _ ->
                    editView general post author

                Create post author _ ->
                    createView general post author

                Delete post author _ ->
                    deleteView theme (Post.uuid post)
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


notLoggedInView : Theme -> List (Html Msg)
notLoggedInView theme =
    []


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


peekView : General -> Post Core Full -> List (Html Msg)
peekView general post =
    let
        theme =
            General.theme general
    in
    [ sheet theme
        []
    ]


editView : General -> Post Core Full -> Author -> List (Html Msg)
editView general post author =
    let
        theme =
            General.theme general
    in
    [ sheet theme
        [ div
            [ css
                [ Style.Card.headingStyle theme ]
            ]
            [ authorLink author theme
            , divider theme
            , titleInput theme <| Post.title post
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
        , descInput theme <| Post.description post
        , h3
            [ css
                [ textAreaLabelStyle
                , margin4 (px 0) (px 0) (px 0) (px 15)
                ]
            ]
            [ text "Body" ]
        , bodyInput theme <| Post.body post
        , div
            [ css [ displayFlex ]
            ]
            [ button
                [ Events.onClick <| GeneralMsg <| GoBack
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
                , Events.onClick Write
                ]
                [ text "Edit" ]
            ]
        ]
    ]


createView : General -> Post Client Full -> Author -> List (Html Msg)
createView general post author =
    let
        theme =
            General.theme general
    in
    [ sheet theme
        [ div
            [ css
                [ Style.Card.headingStyle theme
                ]
            ]
            [ authorLink author theme
            , divider theme
            , titleInput theme <| Post.title post
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
        , descInput theme <| Post.description post
        , h3
            [ css
                [ textAreaLabelStyle
                , margin4 (px 0) (px 0) (px 0) (px 15)
                ]
            ]
            [ text "Body" ]
        , bodyInput theme <| Post.body post
        , div
            [ css
                [ displayFlex ]
            ]
            [ button
                [ Events.onClick <| GeneralMsg <| GoBack
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
                , Events.onClick Write
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
                    [ Events.onClick <| GeneralMsg GoBack
                    , css
                        [ Style.Button.default
                        , backgroundColor <| Color.danger theme
                        , marginRight <| px 15
                        ]
                    ]
                    [ text "Go Back" ]
                , button
                    [ Events.onClick <| ConfirmDelete
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


readyView : General -> Post Core Full -> Author -> List (Html Msg)
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

        fullscreen =
            General.fullscreen general

        myPost =
            case General.user general of
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


viewTags : General -> Post l f -> Html msg
viewTags general post =
    let
        theme =
            General.theme general

        tags =
            Post.tags post
                |> List.map (\tagUUID -> Tag.find tagUUID (General.tags general))
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


favorite : General -> Post Core f -> List Style -> Html Msg
favorite general post styles =
    let
        theme =
            General.theme general

        fav =
            Post.favorite post
    in
    View.Svg.heart
        [ SvgEvents.onClick ToggleFavorite
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
            Post.published post

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
        [ SvgEvents.onClick (GeneralMsg <| FullscreenElement "post-page")
        , SvgAttributes.css
            [ svgStyle theme
            , Css.batch styles
            ]
        ]


minimize : Theme -> List Style -> Html Msg
minimize theme styles =
    View.Svg.minimize
        [ SvgEvents.onClick (GeneralMsg ExitFullscreen)
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
        , Events.onInput OnTitleInput
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
        , Events.onInput OnDescriptionInput
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
        , Events.onInput OnBodyInput
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
