module Data.Post exposing (Client, Core, Full, Post, Preview, date, author, body, compare, description, empty, encodeFreshFull, encodeFull, encodePreview, fullDecoder, mapBody, mapDescription, mapPublished, mapTitle, previewDecoder, published, tags, title, toPreview, uuid)

import Data.Markdown as Markdown exposing (Markdown)
import Data.UUID as UUID exposing (UUID)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (custom, hardcoded, required)
import Json.Encode as Encode exposing (Value)
import Time



{- Model -}
-- Represents a Post
-- location: where the post is stored (client/server)
-- content: what content post contains (preview/full)


type Post location content
    = Post location content Internals



-- For posts stored on core


type Core
    = Core CoreInternals


type alias CoreInternals =
    { uuid : UUID
    , date : Time.Posix
    }



-- For posts stored on client (hasn't been created on server yet)


type Client
    = Client



-- For posts containing all data


type Full
    = Full FullInternals


type alias FullInternals =
    { body : Markdown
    }



-- For posts only containing low-storage data


type Preview
    = Preview



-- fields contained by ALL posts


type alias Internals =
    { title : String
    , description : String
    , tags : List UUID
    , author : UUID
    , published : Bool
    }



{- Accessors -}


uuid : Post Core c -> UUID
uuid post =
    accessCore .uuid post


description : Post l c -> String
description post =
    accessInternals .description post


mapDescription : (String -> String) -> Post l c -> Post l c
mapDescription transform post =
    mapInternals (\i -> { i | description = transform i.description }) post


title : Post l c -> String
title post =
    accessInternals .title post


mapTitle : (String -> String) -> Post l c -> Post l c
mapTitle transform post =
    mapInternals (\i -> { i | title = transform i.title }) post


body : Post l Full -> Markdown
body post =
    accessFull .body post


mapBody : (Markdown -> Markdown) -> Post l Full -> Post l Full
mapBody transform post =
    mapFull (\c -> { c | body = transform c.body }) post


author : Post l c -> UUID
author post =
    accessInternals .author post


date : Post Core c -> Time.Posix
date post =
    accessCore .date post



tags : Post l c -> List UUID
tags post =
    accessInternals .tags post


published : Post l c -> Bool
published post =
    accessInternals .published post


mapPublished : (Bool -> Bool) -> Post l c -> Post l c
mapPublished transform post =
    mapInternals (\i -> { i | published = transform i.published }) post



{- Util -}


toPreview : Post l c -> Post l Preview
toPreview (Post l _ i) =
    Post l Preview i


compare : Post Core x -> Post Core y -> Bool
compare (Post (Core a) _ _) (Post (Core b) _ _) =
    UUID.compare a.uuid b.uuid


accessInternals : (Internals -> a) -> Post l c -> a
accessInternals accessor (Post _ _ internals) =
    internals
        |> accessor


mapInternals : (Internals -> Internals) -> Post l c -> Post l c
mapInternals transform (Post l c internals) =
    Post l c <| transform internals


accessCore : (CoreInternals -> a) -> Post Core c -> a
accessCore accessor (Post (Core core) _ _) =
    core
        |> accessor


accessFull : (FullInternals -> a) -> Post l Full -> a
accessFull accessor (Post _ (Full full) _) =
    full
        |> accessor


mapFull : (FullInternals -> FullInternals) -> Post l Full -> Post l Full
mapFull transform (Post l (Full full) i) =
    Post l (Full <| transform full) i


empty : UUID -> Post Client Full
empty userUUID =
    Post
        Client
        (Full
            { body = Markdown.create ""
            }
        )
        { title = ""
        , description = ""
        , tags = []
        , author = userUUID
        , published = False
        }


{- Json -}
-- Encoders


encodeInternalsHelper : Internals -> List ( String, Value )
encodeInternalsHelper i =
    [ ( "title", Encode.string i.title )
    , ( "description", Encode.string i.description )
    , ( "tags", Encode.list UUID.encode i.tags )
    , ( "author", UUID.encode i.author )
    , ( "published", Encode.bool i.published )
    ]


encodeFullHelper : FullInternals -> List ( String, Value )
encodeFullHelper i =
    [ ( "body", Markdown.encode i.body )
    ]


encodeCoreHelper : CoreInternals -> List ( String, Value )
encodeCoreHelper i =
    [ ( "date", Encode.int <| Time.posixToMillis i.date )
    , ( "uuid", UUID.encode i.uuid )
    ]


encodeFull : Post Core Full -> Value
encodeFull (Post (Core coreInternals) (Full fullInternals) internals) =
    Encode.object
        ([]
            |> (++) (encodeInternalsHelper internals)
            |> (++) (encodeFullHelper fullInternals)
            |> (++) (encodeCoreHelper coreInternals)
        )


encodePreview : Post Core Preview -> Value
encodePreview (Post (Core coreInternals) _ internals) =
    Encode.object
        ([]
            |> (++) (encodeInternalsHelper internals)
            |> (++) (encodeCoreHelper coreInternals)
        )


encodeFreshFull : Post Client Full -> Value
encodeFreshFull (Post _ (Full fullInternals) internals) =
    Encode.object
        ([]
            |> (++) (encodeInternalsHelper internals)
            |> (++) (encodeFullHelper fullInternals)
        )



-- Decoders


internalsDecoder : Decoder Internals
internalsDecoder =
    Decode.succeed Internals
        |> required "title" Decode.string
        |> required "description" Decode.string
        |> required "tags" (Decode.list UUID.decoder)
        |> required "author" UUID.decoder
        |> required "published" Decode.bool


coreDecodeHelper : Maybe Bool -> Decoder Core
coreDecodeHelper defaultFav =
    Decode.succeed CoreInternals
        |> required "uuid" UUID.decoder
        |> required "date" timeDecoder
        |> Decode.map Core


fullDecodeHelper : Decoder Full
fullDecodeHelper =
    Decode.succeed FullInternals
        |> required "body" Markdown.decoder
        |> Decode.map Full


timeDecoder : Decoder Time.Posix
timeDecoder =
    Decode.int
        |> Decode.andThen
            (\int ->
                Decode.succeed (Time.millisToPosix int)
            )


previewDecoder : Maybe Bool -> Decoder (Post Core Preview)
previewDecoder defaultFav =
    Decode.succeed Post
        |> custom (coreDecodeHelper defaultFav)
        |> hardcoded Preview
        |> custom internalsDecoder


fullDecoder : Decoder (Post Core Full)
fullDecoder =
    Decode.succeed Post
        |> custom (coreDecodeHelper Nothing)
        |> custom fullDecodeHelper
        |> custom internalsDecoder
