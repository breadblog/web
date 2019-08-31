module Page.Post exposing (Model, Msg, fromGeneral, init, toGeneral, update, view)

import Api
import Data.Author as Author exposing (Author)
import Data.General as General exposing (General)
import Data.Post as Post exposing (Client, Core, Full, Post)
import Data.Route as Route exposing (PostRoute(..), Route(..))
import Data.UUID as UUID exposing (UUID)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events as Events
import Http



{- Model -}


type Model
    = Model General Internals


type
    Internals
    {------------------ Public States ---------------------}
    -- loading state for when we are fetching post info
    = LoadingView
      -- we are now ready to display an existing post
    | View (Post Core Full) Author
      -- page shown when failure occurs, waiting for redirect
      -- to home page
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
    | Delete (Post Core Full)
    | NotLoggedIn


init : General -> PostRoute -> ( Model, Cmd Msg )
init general postRoute =
    let
        route =
            General.route general

        mode =
            General.mode general
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
                    ( Model general (Create <| Post.empty <| Author.uuid author)
                    , Cmd.none
                    )

                Nothing ->
                    ( Model general NotLoggedIn
                    , Cmd.map GeneralMsg <| General.logout general
                    )

        Route.View postUUID ->
            case General.user general of
                Just userUUID ->
                    ( Model general LoadingView
                    , Api.getPost mode postUUID
                    )

        Route.Edit postUUID ->
            case General.user general of
                Just userUUID ->
                    ( Model general LoadingEdit
                    , Api.getPost mode postUUID
                    )

                Nothing ->
                    ( Model general NotLoggedIn
                    , Cmd.none
                    )

        Route.Delete postUUID ->
            case General.user general of
                Just userUUID ->
                    ( LoadingDelete, Api.getPost mode postUUID )

                Nothing ->
                    ( NotLoggedIn, Cmd.none )


toGeneral : Model -> General
toGeneral (Model general internals) =
    general



{- Message -}


type Msg
    = GotPost (Result Http.Error (Post Core Full))
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



{- Update -}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        (Model general internals) =
            model

        replaceMe =
            ( model, Cmd.none )
    in
    case msg of
        GotPost res ->
            gotPost model res

        OnTitleInput str ->
            case internals of
                Create post author ->
                    ( Model
                        general
                        (Create (Post.mapTitle (always <| String.left 64 <| str) post) author)
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        OnDescriptionInput str ->
            replaceMe

        OnBodyInput str ->
            replaceMe

        Write ->
            replaceMe

        GotWrite res ->
            replaceMe

        EditCurrentPost ->
            replaceMe

        DeleteCurrentPost ->
            replaceMe

        ConfirmDelete ->
            replaceMe

        GotDelete res ->
            replaceMe

        TogglePublished ->
            case internals of
                Edit post _ ->
                    ( Post.mapPublished not post
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
                        |> Maybe.map2 UUID.compare (General.user general)
                        |> Maybe.withDefault False
            in
            case maybeAuthor of
                Just author ->
                    case internals of
                        LoadingView ->
                            ( Model general (View post author)
                            , Cmd.none
                            )

                        LoadingEdit ->
                            if userIsAuthor then
                                ( Model general (Edit post author)
                                , Cmd.none
                                )

                            else
                                let
                                    handlerMsg =
                                        GotPost res

                                    handler =
                                        Problem.createHandler "View Post" handlerMsg

                                    problem =
                                        Problem.create "Cannot edit post" (HttpError err) (Just handler)

                                    updatedGeneral =
                                        General.pushProblem problem general
                                in
                                ( Model updatedGeneral LoadingView
                                , Cmd.none
                                )

                Nothing ->
                    let
                        handlerMsg =
                            NavigateTo Home

                        handler =
                            Problem.createHandler "Go Home" handlerMsg

                        problem =
                            Problem.create "Post Author Missing"

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
view (Model general internals) =
    let
        theme =
            General.theme general

        contents =
            case internals of
                LoadingView ->
                    loadingView theme

                Redirect ->
                    [ div [ css [ flexGrow <| num 1 ] ] [] ]

                View post author ->
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
