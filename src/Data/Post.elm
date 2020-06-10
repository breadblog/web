module Data.Post exposing (Client, Core, Full, Post, Preview, empty, getUUID)

import Action exposing (Action)
import Data.Markdown as Markdown exposing (Markdown)
import Data.Mode exposing (Mode)
import Data.UUID as UUID exposing (UUID)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (custom, required)
import Json.Encode as Encode exposing (Value)
import Task exposing (Task)
import Time



{- Model -}


type Post location content
    = Post location content Internals



-- For posts stored on core


type Core
    = Core ICore


type alias ICore =
    { uuid : UUID
    , date : Time.Posix
    , author : Action
    , tags : List Action
    }


type alias TagAction =
    { show : Maybe Action
    }


type alias AuthorAction =
    { show : Maybe Action }



-- For posts stored on client (hasn't been created on server yet)


type Client
    = Client IClient


type alias IClient =
    { author : UUID
    , tags : List UUID
    }



-- For posts containing all data


type Full
    = Full IFull


type alias IFull =
    { body : Markdown
    }



-- For posts only containing low-storage data


type Preview
    = Preview IPreview


type alias IPreview =
    {}



-- fields contained by ALL posts


type alias Internals =
    { title : String
    , description : String
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


getDate : Post Core c -> Time.Posix
getDate post =
    accessCore .date post


getTags : Post Core c -> List Action
getTags post =
    accessCore .tags post


getPublished : Post l c -> Bool
getPublished post =
    accessInternals .published post


mapPublished : (Bool -> Bool) -> Post l c -> Post l c
mapPublished transform post =
    mapInternals (\i -> { i | published = transform i.published }) post



{- Util -}


toPreview : Post l c -> Post l Preview
toPreview (Post l _ i) =
    Post l (Preview {}) i


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


accessCore : (ICore -> a) -> Post Core c -> a
accessCore accessor (Post (Core core) _ _) =
    core
        |> accessor


accessFull : (IFull -> a) -> Post l Full -> a
accessFull accessor (Post _ (Full full) _) =
    full
        |> accessor


accessClient : (IClient -> a) -> Post Client c -> a
accessClient accessor (Post (Client client) _ _) =
    client |> accessor


mapFull : (IFull -> IFull) -> Post l Full -> Post l Full
mapFull transform (Post l (Full full) i) =
    Post l (Full <| transform full) i


empty : UUID -> Post Client Full
empty author =
    Post
        (Client
            { author = author
            , tags = []
            }
        )
        (Full
            { body = Markdown.create ""
            }
        )
        { title = ""
        , description = ""
        , published = False
        }



{- Json -}


encodeFull : Full -> List ( String, Value )
encodeFull (Full full) =
    [ ( "body", Markdown.encode full.body )
    ]


encodePreview : Preview -> List ( String, Value )
encodePreview (Preview preview) =
    []


encodeCore : Core -> List ( String, Value )
encodeCore (Core core) =
    [ ( "date", Encode.int <| Time.posixToMillis core.date )
    , ( "uuid", UUID.encode core.uuid )
    ]


encodeClient : Client -> List ( String, Value )
encodeClient (Client client) =
    [ ( "tags", Encode.list UUID.encode client.tags )
    , ( "author"
      , UUID.encode client.author
      )
    ]


encodeInternals : Internals -> List ( String, Value )
encodeInternals internals =
    [ ( "title", Encode.string internals.title )
    , ( "description", Encode.string internals.description )
    , ( "published", Encode.bool internals.published )
    ]


encodeCoreFull : Post Core Full -> Value
encodeCoreFull (Post core full internals) =
    Encode.object
        ([]
            |> (++) (encodeInternals internals)
            |> (++) (encodeCore core)
            |> (++) (encodeFull full)
        )


encodeClientFull : Post Client Full -> Value
encodeClientFull (Post client full internals) =
    Encode.object
        ([]
            |> (++) (encodeInternals internals)
            |> (++) (encodeClient client)
            |> (++) (encodeFull full)
        )


encodeCorePreview : Post Core Preview -> Value
encodeCorePreview (Post core preview internals) =
    Encode.object
        ([]
            |> (++) (encodeInternals internals)
            |> (++) (encodePreview preview)
            |> (++) (encodeCore core)
        )


encodeClientPreview : Post Client Preview -> Value
encodeClientPreview (Post client preview internals) =
    Encode.object
        ([]
            |> (++) (encodeInternals internals)
            |> (++) (encodeClient client)
            |> (++) (encodePreview preview)
        )


internalsDecoder : Decoder Internals
internalsDecoder =
    Decode.succeed Internals
        |> required "getTitle" Decode.string
        |> required "getDescription" Decode.string
        |> required "getPublished" Decode.bool


coreDecoder : Decoder Core
coreDecoder =
    Decode.succeed ICore
        |> required "uuid" UUID.decoder
        |> required "date" timeDecoder
        |> required "author" Action.decoder
        |> required "tags" (Decode.list Action.decoder)
        |> Decode.map Core

tagActionDecoder : Decoder TagAction
tagActionDecoder =
    Decode.succeed TagAction
        |> required "show" (Decode.maybe Action.decoder)


authorActionDecoder : Decoder AuthorAction
authorActionDecoder =
    Decode.succeed AuthorAction
        |> required "show" (Decode.maybe Action.decoder)


fullDecoder : Decoder Full
fullDecoder =
    Decode.succeed IFull
        |> required "getBody" Markdown.decoder
        |> Decode.map Full


previewDecoder : Decoder Preview
previewDecoder =
    Decode.succeed IPreview
        |> Decode.map Preview


clientDecoder : Decoder Client
clientDecoder =
    Decode.succeed IClient
        |> required "author" UUID.decoder
        |> required "tags" (Decode.list UUID.decoder)
        |> Decode.map Client


timeDecoder : Decoder Time.Posix
timeDecoder =
    Decode.int
        |> Decode.andThen
            (\int ->
                Decode.succeed (Time.millisToPosix int)
            )


corePreviewDecoder : Decoder (Post Core Preview)
corePreviewDecoder =
    Decode.succeed Post
        |> custom coreDecoder
        |> custom previewDecoder
        |> custom internalsDecoder


coreFullDecoder : Decoder (Post Core Full)
coreFullDecoder =
    Decode.succeed Post
        |> custom coreDecoder
        |> custom fullDecoder
        |> custom internalsDecoder


clientPreviewDecoder : Decoder (Post Client Preview)
clientPreviewDecoder =
    Decode.succeed Post
        |> custom clientDecoder
        |> custom previewDecoder
        |> custom internalsDecoder


clientFullDecoder : Decoder (Post Client Full)
clientFullDecoder =
    Decode.succeed Post
        |> custom clientDecoder
        |> custom fullDecoder
        |> custom internalsDecoder
