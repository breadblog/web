module Page.Post exposing (Model, view, toSession, init)

import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events
import Message exposing (Msg)
import Style.Post
import Time
import Data.Session exposing (Session)
import Data.Post exposing (Post)
import Data.Cache as Cache exposing (Cache)
import View.Markdown as Markdown


type alias Model =
    { session : Session
    , cache : Cache
    , post : Maybe Post
    }


init : { session : Session, cache : Cache } -> ( Model, Cmd Msg )
init { session, cache } =
    -- TODO: How are these formatted?
    ( { session = session
        , cache = cache
        , post = Nothing
        }
    , Cmd.none
    )


toSession : Model -> Session
toSession model =
    model.session


view : Model -> Html Msg
view model =
    let
        post =
            { title = "My Post"
            , author = "Parasrah"
            , date = Time.millisToPosix 1550810346641
            , content = content
            }

        theme =
            Cache.theme model.cache

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
