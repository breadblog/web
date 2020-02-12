module Data.Post exposing (Client, Core, Full, Post, Preview, author, body, compare, description, empty, encodeFreshFull, encodeFull, encodePreview, favorite, fullDecoder, mapBody, mapDescription, mapFavorite, mapPublished, mapTitle, mergeFromApi, previewDecoder, published, tags, title, toPreview, uuid)

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
-- Represents a Post
-- location: where the post is stored (client/server)
-- fields: what fields post contains (preview/full)


type Post location fields
    = Post location fields Internals



-- For posts stored on core


type Core
    = Core CoreInternals


type alias CoreInternals =
    { uuid : UUID
    , date : Time.Posix
    , favorite : Maybe Bool
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


uuid : Post Core f -> UUID
uuid post =
    accessCore .uuid post


description : Post l f -> String
description post =
    accessInternals .description post


mapDescription : (String -> String) -> Post l f -> Post l f
mapDescription transform post =
    mapInternals (\i -> { i | description = transform i.description }) post


title : Post l f -> String
title post =
    accessInternals .title post


mapTitle : (String -> String) -> Post l f -> Post l f
mapTitle transform post =
    mapInternals (\i -> { i | title = transform i.title }) post


body : Post l Full -> Markdown
body post =
    accessFull .body post


mapBody : (Markdown -> Markdown) -> Post l Full -> Post l Full
mapBody transform post =
    mapFull (\f -> { f | body = transform f.body }) post


author : Post l f -> UUID
author post =
    accessInternals .author post


date : Post Core f -> Time.Posix
date post =
    accessCore .date post


favorite : Post Core f -> Maybe Bool
favorite post =
    accessCore .favorite post


mapFavorite : (Maybe Bool -> Maybe Bool) -> Post Core f -> Post Core f
mapFavorite transform post =
    mapCore (\i -> { i | favorite = transform i.favorite }) post


tags : Post l f -> List UUID
tags post =
    accessInternals .tags post


published : Post l f -> Bool
published post =
    accessInternals .published post


mapPublished : (Bool -> Bool) -> Post l f -> Post l f
mapPublished transform post =
    mapInternals (\i -> { i | published = transform i.published }) post



{- Util -}


toPreview : Post c f -> Post c Preview
toPreview (Post c f i) =
    Post c Preview i


compare : Post Core x -> Post Core y -> Bool
compare (Post (Core a) _ _) (Post (Core b) _ _) =
    UUID.compare a.uuid b.uuid


accessInternals : (Internals -> a) -> Post l f -> a
accessInternals accessor (Post l f internals) =
    internals
        |> accessor


mapInternals : (Internals -> Internals) -> Post l f -> Post l f
mapInternals transform (Post l f internals) =
    Post l f <| transform internals


accessCore : (CoreInternals -> a) -> Post Core f -> a
accessCore accessor (Post (Core core) _ _) =
    core
        |> accessor


mapCore : (CoreInternals -> CoreInternals) -> Post Core f -> Post Core f
mapCore transform (Post (Core core) f i) =
    Post (Core <| transform core) f i


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


toSource : msg -> List (Post l f) -> Source msg
toSource msg posts =
    Search.source
        (List.map
            title
            posts
        )
        "post"
        msg


mergeFromApi : Post Core Preview -> Post Core Preview -> Post Core Preview
mergeFromApi fromAPI (Post (Core fromCache) _ _) =
    mapFavorite (\_ -> fromCache.favorite) fromAPI


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
    List.append
        [ ( "date", Encode.int <| Time.posixToMillis i.date )
        , ( "uuid", UUID.encode i.uuid )
        ]
        (case i.favorite of
            Just v ->
                [ ( "favorite", Encode.bool v ) ]

            Nothing ->
                []
        )


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
        |> optional "favorite" (Decode.maybe Decode.bool) defaultFav
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
