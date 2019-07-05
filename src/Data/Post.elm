module Data.Post exposing (Full, Post, Preview, author, body, compare, description, encodeFull, encodePreview, fullDecoder, mergeFromApi, previewDecoder, title)

import Data.Author as Author exposing (Author)
import Data.Markdown as Markdown exposing (Markdown)
import Data.Search as Search exposing (Source)
import Data.Tag as Tag exposing (Tag)
import Data.UUID as UUID exposing (UUID)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (custom, hardcoded, optional, required)
import Json.Encode as Encode exposing (Value)
import Time



{- Model -}


type Post extra
    = Post extra Internals


type alias Body =
    Markdown


type Full
    = Full Body


type Preview
    = Preview


type alias Internals =
    { uuid : UUID
    , title : String
    , description : String
    , tags : List UUID
    , author : UUID
    , date : Time.Posix
    , published : Bool
    , favorite : Bool
    }



{- Accessors -}


uuid : Post e -> UUID
uuid (Post e post) =
    post.uuid


description : Post e -> String
description (Post e post) =
    post.description


title : Post e -> String
title (Post e post) =
    post.title


mapTitle : (String -> String) -> Post e -> Post e
mapTitle fn (Post e post) =
    Post e
        { post | title = fn post.title }


body : Post Full -> Body
body (Post (Full body_) post) =
    body_


mapBody : (Body -> Body) -> Post Full -> Post Full
mapBody fn (Post (Full body_) post) =
    Post
        (Full (fn body_))
        post


author : Post e -> UUID
author (Post e post) =
    post.author


date : Post e -> Time.Posix
date (Post e post) =
    post.date



{- Util -}


toSource : msg -> List (Post e) -> Source msg
toSource msg posts =
    Search.source
        (List.map
            title
            posts
        )
        "post"
        msg


compare : Post e -> Post e -> Bool
compare (Post _ a) (Post _ b) =
    a.uuid == b.uuid


mergeFromApi : Post Preview -> Post Preview -> Post Preview
mergeFromApi (Post _ a) (Post _ b) =
    Post Preview { a | favorite = b.favorite }



{- JSON -}
-- Encoders


encodeFull : Post Full -> Value
encodeFull (Post (Full body_) internals) =
    Encode.object <|
        List.append
            (internalsEncoder internals)
            [ ( "body", Markdown.encode body_ ) ]


encodePreview : Post Preview -> Value
encodePreview (Post Preview internals) =
    Encode.object <|
        internalsEncoder internals


internalsEncoder : Internals -> List ( String, Value )
internalsEncoder internals =
    [ ( "uuid", UUID.encode internals.uuid )
    , ( "title", Encode.string internals.title )
    , ( "description", Encode.string internals.description )
    , ( "tags", Encode.list UUID.encode internals.tags )
    , ( "author", UUID.encode internals.author )
    , ( "date", Encode.int (Time.posixToMillis internals.date) )
    , ( "published", Encode.bool internals.published )
    , ( "favorite", Encode.bool internals.favorite )
    ]



-- Decoders


internalsDecoder : Decoder Internals
internalsDecoder =
    Decode.succeed Internals
        |> required "uuid" UUID.decoder
        |> required "title" Decode.string
        |> required "description" Decode.string
        |> required "tags" (Decode.list UUID.decoder)
        |> required "author" UUID.decoder
        |> required "date" timeDecoder
        |> required "published" Decode.bool
        |> optional "favorite" Decode.bool True


timeDecoder : Decoder Time.Posix
timeDecoder =
    Decode.int
        |> Decode.andThen
            (\int ->
                Decode.succeed (Time.millisToPosix int)
            )


previewDecoder : Decoder (Post Preview)
previewDecoder =
    Decode.succeed Post
        |> hardcoded Preview
        |> custom internalsDecoder


fullDecoder : Decoder (Post Full)
fullDecoder =
    Decode.succeed Post
        |> required "body" (Decode.map Full Markdown.decoder)
        |> custom internalsDecoder
