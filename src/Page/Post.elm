module Page.Post exposing (Model, Msg, fromGeneral, init, toGeneral, view, update)

import Data.Cache as Cache exposing (Cache)
import Data.Post exposing (Post)
import Data.Session exposing (Session)
import Data.Theme exposing (Theme)
import Data.General as General exposing (General)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events
import Message exposing (Msg(..), Compound(..))
import Style.Post
import Time
import View.Markdown as Markdown


type alias Model =
    { cache : Cache
    , session : Session
    }


init : (Model -> e) -> General -> ( e, Cmd msg )
init transform general =
    ( transform <|
        { session = General.session general
        , cache = General.cache general
        }
    , Cmd.none
    )


fromGeneral : General -> Model -> Model
fromGeneral general model =
    { model | cache = General.cache general, session = General.session general }


toGeneral : Model -> General
toGeneral model =
    General.init model.session model.cache


-- Message --


type Msg
    = NoOp


-- Update --


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    ( model, Cmd.none )


-- View --


view : Model -> Html (Compound Msg)
view model =
    let
        theme =
            Cache.theme model.cache

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
    div
        [ class name ]
        [ h1
            [ class "title" ]
            [ text post.title ]
        , h2
            [ class "author" ]
            [ text post.author ]
        , Markdown.toHtml name postStyle.content post.content
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
