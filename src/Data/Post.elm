module Data.Post exposing (Post, decoder, encode)

import Data.PostId as PostId exposing (PostId)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)
import Time


type Post
    = Post Internals


type alias Internals =
    { id : PostId
    , title : String
    , content : String
    , author : String
    , date : Time.Posix
    }



-- READONLY id


id : Post -> PostId
id (Post post) =
    post.id



-- READWRITE title


title : Post -> String
title (Post post) =
    post.title


mapTitle : (String -> String) -> Post -> Post
mapTitle fn (Post post) =
    Post
        { post | title = fn post.title }



-- READWRITE content


content : Post -> String
content (Post post) =
    post.content


mapContent : (String -> String) -> Post -> Post
mapContent fn (Post post) =
    Post
        { post | content = fn post.content }



-- READONLY author


author : Post -> String
author (Post post) =
    post.author



-- READONLY date


date : Post -> Time.Posix
date (Post post) =
    post.date



-- JSON


timeDecoder : Decoder Time.Posix
timeDecoder =
    Decode.int
        |> Decode.andThen
            (\int ->
                Decode.succeed (Time.millisToPosix int)
            )


encode : Post -> Value
encode (Post post) =
    Encode.object
        [ ( "id", PostId.encode post.id )
        , ( "title", Encode.string post.title )
        , ( "content", Encode.string post.content )
        , ( "author", Encode.string post.author )
        , ( "date", Encode.int (Time.posixToMillis post.date) )
        ]


decoder : Decoder Post
decoder =
    Decode.succeed Internals
        |> required "id" PostId.decoder
        |> required "title" Decode.string
        |> required "content" Decode.string
        |> required "author" Decode.string
        |> required "date" timeDecoder
        |> Decode.map Post
