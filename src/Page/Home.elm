module Page.Home exposing (Model, Msg, fromGeneral, init, toGeneral, update, view)

import Browser.Dom exposing (Viewport)
import Css exposing (..)
import Data.General as General exposing (General)
import Data.Personalize as Personalize exposing (Row)
import Data.Post as Post exposing (Core, Post, Preview)
import Data.Route as Route exposing (Route(..))
import Data.Theme exposing (Theme)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, css, href)
import Html.Styled.Events exposing (onClick)
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


type alias Internals =
    { positions : List Int
    }


init : General -> Page.TransformModel Internals mainModel -> Page.TransformMsg ModMsg mainMsg -> ( mainModel, Cmd mainMsg )
init =
    Page.init
        Internals
        Cmd.none
        Home


toGeneral : Model -> General
toGeneral =
    Page.toGeneral


fromGeneral : General -> Model -> Model
fromGeneral =
    Page.fromGeneral



-- Message --


type alias Msg =
    Page.Msg ModMsg


type ModMsg
    = NoOp



{- Update -}


update : Msg -> Model -> PageUpdateOutput ModMsg Internals
update =
    Page.update updateMod


updateMod : ModMsg -> General -> Internals -> Update.Output ModMsg Internals
updateMod msg general internals =
    case msg of
        NoOp ->
            { model = internals
            , cmd = Cmd.none
            , general = general
            }



{- Helpers -}


type alias Rect =
    { width : CardWidth
    , height : Float
    }


type CardWidth
    = Pixels Float
    | Full


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
    in
    [ main_
        [ css
            [ flexGrow <| num 1
            , flexDirection column
            , overflowX hidden
            ]
        ]
        (case isReady general of
            Ready rows screen ->
                readyView theme screen rows

            Loading ->
                loadingView theme
        )
    ]


type FromGeneral
    = Ready (List Row) Viewport
    | Loading


isReady : General -> FromGeneral
isReady general =
    let
        dataReady =
            General.dataReady general

        maybeScreen =
            General.screen general

        visits =
            General.visits general

        authors =
            General.authors general

        tags =
            General.tags general

        posts =
            General.postPreviews general

        rows =
            Personalize.personalize visits authors tags posts
    in
    case ( dataReady, maybeScreen ) of
        ( True, Just screen ) ->
            Ready rows screen

        ( _, _ ) ->
            Loading


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
