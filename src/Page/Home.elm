module Page.Home exposing (Model, Msg, fromGeneral, init, toGeneral, update, view)

import Api
import Browser.Dom exposing (Viewport)
import Css exposing (..)
import Data.Author as Author exposing (Author)
import Data.General as General exposing (General)
import Data.Personalize as Personalize exposing (Card, Row)
import Data.Post as Post exposing (Core, Post, Preview)
import Data.Route as Route exposing (Route(..))
import Data.Tag as Tag exposing (Tag)
import Data.Theme exposing (Theme)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href)
import Html.Styled.Events exposing (onClick)
import Http
import Message exposing (Compound(..))
import Style.Card
import Style.Color as Color
import Update
import View.Footer as Footer
import View.Header as Header
import View.Loading
import View.Page as Page exposing (PageUpdateOutput)



-- Model


type alias Model =
    Page.PageModel Internals


type alias Row =
    { index : Int
    , label : String
    , cards : List Card
    }


type Internals
    = Loading ILoading
    | Ready (List Row)


type alias ILoading =
    { posts : List (Post Core Preview)
    , postsReady : Bool
    , authors : List Author
    , authorsReady : Bool
    , tags : List Tag
    , tagsReady : Bool
    }



{- Init -}


init : General -> Page.TransformModel Internals mainModel -> Page.TransformMsg ModMsg mainMsg -> ( mainModel, Cmd mainMsg )
init general =
    let
        mode =
            General.mode general
    in
    Page.init
        (Loading initLoading)
        (Cmd.batch
            [ Api.getPostPreviews mode GotPosts 0
            , Api.getAuthors mode GotAuthors 0
            , Api.getTags mode GotTags 0
            ]
        )
        Home
        general


initLoading : ILoading
initLoading =
    { posts = []
    , postsReady = False
    , tags = []
    , tagsReady = False
    , authors = []
    , authorsReady = False
    }


toGeneral : Model -> General
toGeneral =
    Page.toGeneral


fromGeneral : General -> Model -> Model
fromGeneral =
    Page.fromGeneral



{- Message -}


type alias Msg =
    Page.Msg ModMsg


type ModMsg
    = GotPosts (Result Http.Error (List (Post Core Preview)))
    | GotAuthors (Result Http.Error (List Author))
    | GotTags (Result Http.Error (List Tag))



{- Update -}


update : Msg -> Model -> PageUpdateOutput ModMsg Internals
update =
    Page.update updateMod


updateMod : ModMsg -> General -> Internals -> Update.Output ModMsg Internals
updateMod msg general internals =
    let
        mode =
            General.mode general
    in
    case internals of
        Loading iLoading ->
            let
                simpleUpdate model =
                    { model = model
                    , general = general
                    , cmd = Cmd.none
                    }

                replaceMe =
                    { model = internals
                    , general = general
                    , cmd = Cmd.none
                    }
            in
            case msg of
                GotAuthors result ->
                    case result of
                        Ok newResources ->
                            Api.onUpdate
                                { oldResources = iLoading.authors
                                , newResources = newResources
                                , getMore =
                                    \page ->
                                        Api.getAuthors mode GotAuthors page
                                , onComplete =
                                    \resources ->
                                        case ( iLoading.postsReady, iLoading.tagsReady ) of
                                            ( True, True ) ->
                                                { posts = iLoading.posts
                                                , tags = iLoading.tags
                                                , authors = resources
                                                }
                                                    |> Ready
                                                    |> simpleUpdate

                                            _ ->
                                                { model = Loading { iLoading | authors = resources }
                                                , general = general
                                                , cmd = Cmd.none
                                                }
                                , onLoading =
                                    \resources cmd ->
                                        { model = Loading { iLoading | authors = resources }
                                        , cmd = cmd
                                        , general = general
                                        }
                                }

                        Err err ->
                            replaceMe

                GotPosts result ->
                    case result of
                        Ok newResources ->
                            replaceMe

                        Err err ->
                            replaceMe

                GotTags result ->
                    case result of
                        Ok newResources ->
                            replaceMe

                        Err err ->
                            replaceMe



{- Helpers -}


type alias Rect =
    { width : CardWidth
    , height : Float
    }


type CardWidth
    = Pixels Float
    | Full


fromPersonalization : Personalize.Row -> Row
fromPersonalization row =
    { label = row.label
    , cards = row.cards
    , index = 0
    }


cardSize : Viewport -> Rect
cardSize screen =
    let
        screenWidth =
            screen.viewport.width

        cardWidth =
            if screenWidth > 2400 then
                Pixels 300

            else if screenWidth > 1600 then
                Pixels 300

            else if screenWidth > 1200 then
                Pixels 300

            else if screenWidth > 800 then
                Pixels 300

            else if screenWidth > 400 then
                Pixels 300

            else
                Full
    in
    case cardWidth of
        Pixels width ->
            Rect cardWidth (width * 3 / 2)

        Full ->
            Rect cardWidth 150


rowMargin : Float
rowMargin =
    10


nextWidth : Float
nextWidth =
    30


columnNumbers : Viewport -> Int
columnNumbers screen =
    let
        screenWidth =
            screen.viewport.width

        cardWidth =
            screen
                |> cardSize
                |> .width
    in
    case cardWidth of
        Full ->
            1

        Pixels pxs ->
            screenWidth
                |> (\a -> a - rowMargin)
                |> (\b -> b - nextWidth)
                |> (\c -> c / pxs)
                |> floor



{- View -}


view : Model -> Page.ViewResult ModMsg
view model =
    Page.view model viewHome


viewHome : General -> Internals -> List (Html (Compound ModMsg))
viewHome general internals =
    let
        theme =
            General.theme general

        maybeScreen =
            General.screen general
    in
    [ main_
        [ css
            [ flexGrow <| num 1
            , flexDirection column
            , overflowX hidden
            ]
        ]
        (case internals of
            Loading _ ->
                loadingView theme

            Ready rows ->
                readyView theme (General.screen general) rows
        )
    ]


loadingView : Theme -> List (Html msg)
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


readyView : Theme -> Viewport -> List Row -> List (Html msg)
readyView theme viewport rows =
    List.map (viewRow theme) rows


viewRow : Theme -> Row -> Html msg
viewRow theme row =
    div
        [ class "row"
        , css
            [ flexGrow (int 1)
            , margin (px 20)
            ]
        ]
        [ h3
            [ class "label"
            , css
                [ fontWeight <| int 500
                , margin (px 0)
                ]
            ]
            [ text row.label ]
        , div
            [ class "posts"
            , css
                [ displayFlex
                , Css.height (px 200)
                ]
            ]
            (List.map
                (viewPost theme)
                row.posts
            )
        ]


viewPost : Theme -> Post Core Preview -> Html msg
viewPost theme post =
    div
        [ class "post"
        , css
            [ Style.Card.style theme
            , displayFlex
            , flexShrink (int 0)
            , flexDirection column
            , Css.width (px 250)
            , margin (px 10)
            , firstChild
                [ marginLeft (px 0) ]
            , lastChild
                [ marginRight (px 0) ]
            ]
        ]
        [ div
            [ class "heading"
            , css
                [ Style.Card.headingStyle theme ]
            ]
            [ h4
                [ class "title"
                , css
                    [ margin (px 0)
                    ]
                ]
                [ text (Post.title post) ]
            ]
        ]
