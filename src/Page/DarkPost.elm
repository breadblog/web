module Page.DarkPost exposing (view)


import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing(..)
import Html.Styled.Events
import Model exposing (Model)
import Message exposing (Msg)
import View.Post
import Time


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
        View.Post.view post

content =
    """
# My Content

This is my content

I hope you like it

* In all seriousness though
* This is clearly not a blog post yet
* And this is under active development
* Lorem Ipsum :D
    """
