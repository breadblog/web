module Page.Post exposing (Model, Msg, fromGeneral, init, toGeneral, update, view)

import Http
import Config
import Data.Cache as Cache exposing (Cache)
import Data.General as General exposing (General)
import Data.Post exposing (Post, Full)
import Data.Route exposing (Route(..))
import Data.Session exposing (Session)
import Data.UUID as UUID exposing (UUID)
import Data.Theme exposing (Theme)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events
import Message exposing (Compound(..), Msg(..))
import Style.Post
import Time
import View.Markdown as Markdown
import View.Page as Page



-- Model --


type alias Model =
    Page.PageModel Internals


type Internals
    = Loading
    | Ready (Post Full)
    | Failure Int


init : UUID -> General -> Page.TransformModel Internals mainModel -> Page.TransformMsg ModMsg mainMsg -> ( mainModel, Cmd mainMsg )
init uuid =
    Page.init
        Loading
        (getPost uuid)
        (Post uuid)


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


update : Msg -> Model -> ( Model, Cmd Msg )
update =
    Page.update updateMod


updateMod : ModMsg -> s -> c -> Internals -> ( Internals, Cmd ModMsg )
updateMod msg _ _ internals =
    case msg of
        GotPost _ ->
            ( internals, Cmd.none )



-- Util --

getPost : UUID -> Cmd ModMsg
getPost uuid =
    let
        path =
            UUID.toPath "/api/post" uuid
    in
    Http.get
        { url = Config.apiUrl ++ path
        , expect = Http.expectJson GotPost Data.Post.fullDecoder
        }
-- View --


view : Model -> Page.ViewResult ModMsg
view model =
    Page.view model viewPost


viewPost : Session -> Cache -> Internals -> List (Html (Compound ModMsg))
viewPost session cache internals =
    let
        theme =
            Cache.theme cache

        post =
            { title = "My Post"
            , author = "Parasrah"
            , date = Time.millisToPosix 1550810346641
            , content = content
            }

        postStyle =
            Style.Post.style theme

        name =
            "post"
    in
    [ div
        [ class name ]
        [ h1
            [ class "title" ]
            [ text post.title ]
        , h2
            [ class "author" ]
            [ text post.author ]
        , Markdown.toHtml name postStyle.content post.content
        ]
    ]


content =
    """
# My Content

This is my content

I hope you like it

* In all seriousness though
* This is clearly not a blog post yet
* And this is under active development
* Lorem Ipsum :D

```elm
view : Model -> Html Msg
view model =
    let
        post =
            { title = "My Post"
            , author = "Parasrah"
            , date = Time.millisToPosix 1550810346641
            , content = content
            }

    in
        View.Post.view "dark-post" post Style.Post.darkPostStyle
```
    """
