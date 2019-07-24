module Page.Post exposing (Model, Msg, fromGeneral, init, toGeneral, update, view)

import Api
import Browser.Navigation as Navigation
import Css exposing (..)
import Css.Transitions as Transitions exposing (transition)
import Data.Author as Author exposing (Author)
import Data.General as General exposing (General, Msg(..))
import Data.Markdown as Markdown exposing (Markdown)
import Data.Post as Post exposing (Client, Core, Full, Post)
import Data.Problem as Problem exposing (Description(..), Problem)
import Data.Route as Route exposing (PostType, Route(..))
import Data.Tag as Tag exposing (Tag)
import Data.Theme exposing (Theme)
import Data.UUID as UUID exposing (UUID)
import Data.Username as Username exposing (Username)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events as Events exposing (onClick, onInput)
import Http
import List.Extra
import Message exposing (Compound(..), Msg(..))
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
import Update
import View.Loading
import View.Page as Page exposing (PageUpdateOutput)
import View.Svg
import View.Tag



{- Model -}


type alias Model =
    Page.PageModel Internals


type
    Internals
    {------------------ Public States ---------------------}
    -- loading state for when we are fetching post info
    = LoadingReady
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
    | LoadingEdit
      -- the following two states are very similar, just one
      -- doesn't have info from core (such as uuid)
    | Edit (Post Core Full) Author
    | Create (Post Client Full) Author
    | Delete UUID



{------------------------------------------------------}


init : PostType -> General -> Page.TransformModel Internals mainModel -> Page.TransformMsg ModMsg mainMsg -> ( mainModel, Cmd mainMsg )
init postType general =
    let
        maybeUserUUID =
            General.user general

        authors =
            General.authors general

        getAuthor =
            \uuid -> Author.fromUUID uuid authors
    in
    case postType of
        Route.Ready postUUID ->
            Page.init
                LoadingReady
                (getPost general postUUID maybeUserUUID Ready)
                (Post <| Route.Ready postUUID)
                general

        Route.Edit postUUID ->
            Page.init
                LoadingEdit
                (getPost general postUUID maybeUserUUID Edit)
                (Post <| Route.Edit postUUID)
                general

        Route.Delete postUUID ->
            Page.init
                (Delete postUUID)
                Cmd.none
                (Post <| Route.Delete postUUID)
                general

        Route.Create ->
            case maybeUserUUID of
                Just userUUID ->
                    case Author.fromUUID userUUID authors of
                        Just author ->
                            Page.init
                                (Create (Post.empty userUUID) author)
                                Cmd.none
                                (Post Route.Create)
                                general

                        Nothing ->
                            Page.init
                                Redirect
                                (redirect404 general)
                                (Post Route.Create)
                                general

                Nothing ->
                    let
                        problem =
                            Problem.create
                                "Not Logged In"
                                (MarkdownError <| Markdown.create "you must be logged in to create a post")
                                (Just <| Problem.createHandler "Log In" (NavigateTo Login))
                    in
                    Page.init
                        LoadingReady
                        Cmd.none
                        (Post Route.Create)
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
    = GotPost ToInternals (Result Http.Error (Post Core Full))
    | OnTitleInput String
    | OnDescriptionInput String
    | OnBodyInput String
    | WritePost
    | WritePostRes (Result Http.Error (Post Core Full))
    | EditCurrentPost
    | DeleteCurrentPost
    | ConfirmDelete
    | OnDelete (Result Http.Error ())
    | TogglePublished



{- Update -}


type alias ToInternals =
    Post Core Full -> Author -> Internals


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

        withProblem problem =
            { model = internals
            , general = General.pushProblem problem general
            , cmd = Cmd.none
            }
    in
    case msg of
        GotPost toInternals res ->
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
                            { model = toInternals post author
                            , general = general
                            , cmd = Cmd.none
                            }

                        Nothing ->
                            { model = Redirect
                            , cmd = redirect404 general
                            , general = general
                            }

                Err err ->
                    -- TODO: handle error properly (might be offline etc)
                    { model = internals
                    , cmd = redirect404 general
                    , general = general
                    }

        -- TODO: implement min chars
        OnTitleInput str ->
            let
                updatePost =
                    \p ->
                        Post.mapTitle
                            (str
                                |> String.left 64
                                |> always
                            )
                            p
            in
            case internals of
                Edit post author ->
                    simpleOutput <| Edit (updatePost post) author

                Create post author ->
                    simpleOutput <| Create (updatePost post) author

                _ ->
                    simpleOutput internals

        OnBodyInput str ->
            let
                updatePost =
                    \p ->
                        Post.mapBody
                            (str
                                |> String.left 100000
                                |> Markdown.create
                                |> always
                            )
                            p
            in
            case internals of
                Edit post author ->
                    simpleOutput <| Edit (updatePost post) author

                Create post author ->
                    simpleOutput <| Create (updatePost post) author

                _ ->
                    simpleOutput internals

        OnDescriptionInput str ->
            let
                updatePost =
                    \p ->
                        Post.mapDescription
                            (str
                                |> String.left 256
                                |> always
                            )
                            p
            in
            case internals of
                Edit post author ->
                    simpleOutput <| Edit (updatePost post) author

                Create post author ->
                    simpleOutput <| Create (updatePost post) author

                _ ->
                    simpleOutput internals

        WritePost ->
            case internals of
                Create post author ->
                    { model = internals
                    , general = general
                    , cmd =
                        Api.put
                            { url = Api.url (General.mode general) "/post/private/"
                            , expect = Http.expectJson (WritePostRes >> Mod) Post.fullDecoder
                            , body = Http.jsonBody <| Post.encodeFreshFull post
                            }
                    }

                Edit post author ->
                    { model = internals
                    , general = general
                    , cmd =
                        Api.post
                            { url = Api.url (General.mode general) "/post/private/"
                            , expect = Http.expectJson (WritePostRes >> Mod) Post.fullDecoder
                            , body = Http.jsonBody <| Post.encodeFull post
                            }
                    }

                _ ->
                    simpleOutput internals

        WritePostRes res ->
            let
                onOk =
                    \post author ->
                        { model = Ready post author
                        , general = general
                        , cmd = Navigation.replaceUrl (General.key general) (Route.toPath <| Post <| Route.Ready <| Post.uuid post)
                        }
            in
            case internals of
                Create _ author ->
                    case res of
                        Ok post ->
                            onOk post author

                        Err err ->
                            withProblem <|
                                Problem.create "Failed to create post" (HttpError err) Nothing

                Edit _ author ->
                    case res of
                        Ok post ->
                            onOk post author

                        Err err ->
                            withProblem <|
                                Problem.create "Failed to edit post" (HttpError err) Nothing

                _ ->
                    simpleOutput internals

        EditCurrentPost ->
            case internals of
                Ready post author ->
                    { model = internals
                    , general = general
                    , cmd = Navigation.pushUrl (General.key general) (Route.toPath <| Post <| Route.Edit <| Post.uuid post)
                    }

                _ ->
                    simpleOutput internals

        DeleteCurrentPost ->
            case internals of
                Ready post author ->
                    { model = internals
                    , general = general
                    , cmd = Navigation.pushUrl (General.key general) (Route.toPath <| Post <| Route.Delete <| Post.uuid post)
                    }

                _ ->
                    simpleOutput internals

        ConfirmDelete ->
            case internals of
                Delete postUUID ->
                    { model = internals
                    , general = general
                    , cmd =
                        Api.delete
                            { url = Api.url (General.mode general) (UUID.toPath "/post/owner" postUUID)
                            , expect = Http.expectWhatever (OnDelete >> Mod)
                            }
                    }

                _ ->
                    simpleOutput internals

        OnDelete res ->
            case res of
                Err err ->
                    withProblem <|
                        Problem.create "Failed to delete post" (HttpError err) Nothing

                Ok _ ->
                    { model = internals
                    , general = general
                    , cmd = Navigation.pushUrl (General.key general) (Route.toPath Home)
                    }

        TogglePublished ->
            case internals of
                Edit post author ->
                    simpleOutput <| Edit (Post.mapPublished not post) author

                Create post author ->
                    simpleOutput <| Create (Post.mapPublished not post) author

                _ ->
                    simpleOutput internals



{- Util -}


type alias PostResult =
    Result Http.Error (Post Core Full)


getPost : General -> UUID -> Maybe UUID -> ToInternals -> Cmd ModMsg
getPost general postUUID maybeUserUUID toInternals =
    let
        path =
            case maybeUserUUID of
                Just _ ->
                    UUID.toPath "/post/private" postUUID

                Nothing ->
                    UUID.toPath "/post/public" postUUID

        mode =
            General.mode general
    in
    Api.get
        { url = Api.url mode path
        , expect = Http.expectJson (GotPost toInternals) Post.fullDecoder
        }


redirect404 : General -> Cmd msg
redirect404 general =
    Navigation.pushUrl (General.key general) (Route.toPath NotFound)



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
                LoadingReady ->
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

                LoadingEdit ->
                    loadingView theme

                Edit post author ->
                    editView general post author

                Create post author ->
                    createView general post author

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
    [ sheet theme
        []
    ]


editView : General -> Post Core Full -> Author -> List (Html (Compound ModMsg))
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
                [ onClick <| Global <| GeneralMsg <| GoBack
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
                , onClick <| Mod <| WritePost
                ]
                [ text "Edit" ]
            ]
        ]
    ]


createView : General -> Post Client Full -> Author -> List (Html (Compound ModMsg))
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
                [ onClick <| Global <| GeneralMsg <| GoBack
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
                , onClick <| Mod <| WritePost
                ]
                [ text "Create" ]
            ]
        ]
    ]


deleteView : Theme -> UUID -> List (Html (Compound ModMsg))
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
                    [ onClick <| Global <| GeneralMsg GoBack
                    , css
                        [ Style.Button.default
                        , backgroundColor <| Color.danger theme
                        , marginRight <| px 15
                        ]
                    ]
                    [ text "Go Back" ]
                , button
                    [ onClick <| Mod <| ConfirmDelete
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


edit : Theme -> List Style -> Html (Compound ModMsg)
edit theme styles =
    View.Svg.edit
        [ SvgEvents.onClick <| Mod <| EditCurrentPost
        , SvgAttributes.css
            [ svgStyle theme
            , Css.batch styles
            ]
        ]


delete : Theme -> List Style -> Html (Compound ModMsg)
delete theme styles =
    View.Svg.trash2
        [ SvgEvents.onClick <| Mod <| DeleteCurrentPost
        , SvgAttributes.css
            [ svgStyle theme
            , Css.batch styles
            ]
        ]


favorite : General -> Post Core f -> List Style -> Html (Compound ModMsg)
favorite general post styles =
    let
        theme =
            General.theme general

        maybeFav =
            case Post.favorite post of
                Just f ->
                    Just f

                Nothing ->
                    case List.Extra.find (Post.compare post) (General.postPreviews general) of
                        Just p ->
                            Post.favorite p

                        Nothing ->
                            Nothing
    in
    case maybeFav of
        Just fav ->
            View.Svg.heart
                [ SvgEvents.onClick <| Global <| GeneralMsg <| TogglePost <| Post.toPreview post
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


togglePublished : Theme -> Post l f -> List Style -> Html (Compound ModMsg)
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
        [ SvgEvents.onClick <| Mod <| TogglePublished
        , SvgAttributes.css
            [ svgStyle theme
            , Css.batch styles
            ]
        ]


maximize : Theme -> List Style -> Html (Compound ModMsg)
maximize theme styles =
    View.Svg.maximize
        [ SvgEvents.onClick <| Global <| GeneralMsg <| FullscreenElement "post-page"
        , SvgAttributes.css
            [ svgStyle theme
            , Css.batch styles
            ]
        ]


minimize : Theme -> List Style -> Html (Compound ModMsg)
minimize theme styles =
    View.Svg.minimize
        [ SvgEvents.onClick <| Global <| GeneralMsg <| ExitFullscreen
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


authorLink : Author -> Theme -> Html (Compound ModMsg)
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


titleInput : Theme -> String -> Html (Compound ModMsg)
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


descInput : Theme -> String -> Html (Compound ModMsg)
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


bodyInput : Theme -> Markdown -> Html (Compound ModMsg)
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
