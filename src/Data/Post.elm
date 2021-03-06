module Data.Post exposing (Client, Core, Full, Post, Preview, compare, delete, edit, empty, encodeFreshFull, encodeFull, encodePreview, fetch, fetchPreviews, fetchPrivate, fullDecoder, getAuthor, getBody, getDate, getDescription, getPublished, getTags, getTitle, getUUID, mapBody, mapDescription, mapPublished, mapTitle, previewDecoder, put, toPreview)

import Api
import Data.Author as Author exposing (Author)
import Data.Markdown as Markdown exposing (Markdown)
import Data.Mode exposing (Mode)
import Data.Tag as Tag exposing (Tag)
import Data.UUID as UUID exposing (UUID)
import Http
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
    , tags : List Tag
    , author : Author
    , published : Bool
    }



{- Accessors -}


getUUID : Post Core c -> UUID
getUUID post =
    accessCore .uuid post


getDescription : Post l c -> String
getDescription post =
    accessInternals .description post


mapDescription : (String -> String) -> Post l c -> Post l c
mapDescription transform post =
    mapInternals (\i -> { i | description = transform i.description }) post


getTitle : Post l c -> String
getTitle post =
    accessInternals .title post


mapTitle : (String -> String) -> Post l c -> Post l c
mapTitle transform post =
    mapInternals (\i -> { i | title = transform i.title }) post


getBody : Post l Full -> Markdown
getBody post =
    accessFull .body post


mapBody : (Markdown -> Markdown) -> Post l Full -> Post l Full
mapBody transform post =
    mapFull (\c -> { c | body = transform c.body }) post


getAuthor : Post l c -> Author
getAuthor post =
    accessInternals .author post


getDate : Post Core c -> Time.Posix
getDate post =
    accessCore .date post


getTags : Post l c -> List Tag
getTags post =
    accessInternals .tags post


getPublished : Post l c -> Bool
getPublished post =
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


empty : Author -> Post Client Full
empty author =
    Post
        Client
        (Full
            { body = Markdown.create ""
            }
        )
        { title = ""
        , description = ""
        , tags = []
        , author = author
        , published = False
        }



{- Http -}


fetch : (Result Http.Error (Post Core Full) -> msg) -> Mode -> UUID -> Cmd msg
fetch toMsg mode uuid =
    Api.get
        { url = Api.url mode <| UUID.toPath "/post/public/" uuid
        , expect = Http.expectJson toMsg fullDecoder
        }


fetchPrivate : (Result Http.Error (Post Core Full) -> msg) -> Mode -> UUID -> Cmd msg
fetchPrivate toMsg mode uuid =
    Api.get
        { url = Api.url mode <| UUID.toPath "/post/private/" uuid
        , expect = Http.expectJson toMsg fullDecoder
        }


fetchPreviews : (Result Http.Error (List (Post Core Preview)) -> msg) -> Mode -> Int -> Cmd msg
fetchPreviews toMsg mode page =
    let
        path =
            "/post?start=" ++ String.fromInt page ++ "&count=" ++ String.fromInt Api.count
    in
    Api.get
        { url = Api.url mode path
        , expect = Http.expectJson toMsg <| Decode.list previewDecoder
        }


delete : (Result Http.Error () -> msg) -> Mode -> UUID -> Cmd msg
delete toMsg mode uuid =
    Api.delete
        { url = Api.url mode <| UUID.toPath "/post/owner/" uuid
        , expect = Http.expectWhatever toMsg
        }


put : (Result Http.Error (Post Core Full) -> msg) -> Mode -> Post Client Full -> Cmd msg
put toMsg mode post =
    Api.put
        { url = Api.url mode "/post/private/"
        , expect = Http.expectJson toMsg fullDecoder
        , body = Http.jsonBody <| encodeFreshFull post
        }


edit : (Result Http.Error (Post Core Full) -> msg) -> Mode -> Post Core Full -> Cmd msg
edit toMsg mode post =
    Api.post
        { url = Api.url mode "/post/private/"
        , expect = Http.expectJson toMsg fullDecoder
        , body = Http.jsonBody <| encodeFull post
        }



{- Json -}


encodeInternalsHelper : Internals -> List ( String, Value )
encodeInternalsHelper i =
    [ ( "title", Encode.string i.title )
    , ( "description", Encode.string i.description )
    , ( "tags", Encode.list (Tag.getUUID >> UUID.encode) i.tags )
    , ( "author"
      , i.author
            |> Author.getUUID
            |> UUID.encode
      )
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


internalsDecoder : Decoder Internals
internalsDecoder =
    Decode.succeed Internals
        |> required "getTitle" Decode.string
        |> required "getDescription" Decode.string
        |> required "getTags" (Decode.list Tag.decoder)
        |> required "getAuthor" Author.decoder
        |> required "getPublished" Decode.bool


coreDecodeHelper : Decoder Core
coreDecodeHelper =
    Decode.succeed CoreInternals
        |> required "uuid" UUID.decoder
        |> required "getDate" timeDecoder
        |> Decode.map Core


fullDecodeHelper : Decoder Full
fullDecodeHelper =
    Decode.succeed FullInternals
        |> required "getBody" Markdown.decoder
        |> Decode.map Full


timeDecoder : Decoder Time.Posix
timeDecoder =
    Decode.int
        |> Decode.andThen
            (\int ->
                Decode.succeed (Time.millisToPosix int)
            )


previewDecoder : Decoder (Post Core Preview)
previewDecoder =
    Decode.succeed Post
        |> custom coreDecodeHelper
        |> hardcoded Preview
        |> custom internalsDecoder


fullDecoder : Decoder (Post Core Full)
fullDecoder =
    Decode.succeed Post
        |> custom coreDecodeHelper
        |> custom fullDecodeHelper
        |> custom internalsDecoder
