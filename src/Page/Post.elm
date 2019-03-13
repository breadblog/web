module Page.Post exposing (Model, init, view, fromGlobal, toGlobal)

import Data.Cache as Cache exposing (Cache)
import Data.Post exposing (Post)
import Data.Session exposing (Session)
import Data.Theme exposing (Theme)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events
import Message exposing (Msg)
import Style.Post
import Time
import View.Markdown as Markdown


type alias Model =
    { cache : Cache
    , session : Session
    }


init : (Model -> e) -> (Session, Cache) -> ( e, Cmd msg )
init transform (session, cache) =
    ( transform <|
        { session = session
        , cache = cache
        }
    , Cmd.none
    )


fromGlobal : (Session, Cache) -> Model -> Model
fromGlobal (session, cache) model =
    { model | cache = cache, session = session }

toGlobal : Model -> (Session, Cache)
toGlobal model =
    (model.session, model.cache)


view : Model -> Html Msg
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
