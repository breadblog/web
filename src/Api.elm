module Api exposing (GetMany, Url, createPost, deletePost, finished, getAuthor, getAuthors, getPost, getPostPreviews, getTag, getTags, login, logout, toOffset, updatePost)

import Data.Author as Author exposing (Author)
import Data.Login
import Data.Mode exposing (Mode(..))
import Data.Password as Password exposing (Password)
import Data.Post as Post exposing (Client, Core, Full, Post, Preview)
import Data.Tag as Tag exposing (Tag)
import Data.UUID as UUID exposing (UUID)
import Data.Username as Username exposing (Username)
import Http exposing (Body, Expect, Header)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)



{- Model -}


type Url
    = Url Internals


type alias Internals =
    { mode : Mode
    , path : String
    }


type alias GetOne r m =
    { msg : Result Http.Error r -> m
    , user : Maybe UUID
    , uuid : UUID
    , mode : Mode
    }


type alias GetMany r m =
    { msg : Result Http.Error (List r) -> m
    , user : Maybe UUID
    , offset : Int
    , mode : Mode
    }


type alias UpdateOne r m =
    { msg : Result Http.Error r -> m
    , user : Maybe UUID
    , resource : r
    , mode : Mode
    }


type alias CreateOne create response m =
    { msg : Result Http.Error response -> m
    , user : Maybe UUID
    , resource : create
    , mode : Mode
    }


type alias DeleteOne m =
    { msg : Result Http.Error () -> m
    , user : Maybe UUID
    , uuid : UUID
    , mode : Mode
    }


type alias Login m =
    { username : Username
    , password : Password
    , msg : Result Http.Error Data.Login.Response -> m
    , mode : Mode
    }


type alias Logout m =
    { msg : Result Http.Error () -> m
    , mode : Mode
    }



{- Public API -}


getPost : GetOne (Post Core Full) msg -> Cmd msg
getPost req =
    let
        path =
            case req.user of
                Just _ ->
                    UUID.toPath "/post/private" req.uuid

                Nothing ->
                    UUID.toPath "/post/public" req.uuid
    in
    get
        { url = url req.mode path
        , expect = Http.expectJson req.msg Post.fullDecoder
        }


getPostPreviews : GetMany (Post Core Preview) msg -> Cmd msg
getPostPreviews req =
    getPage "post" Post.previewDecoder req


createPost : CreateOne (Post Client Full) (Post Core Full) msg -> Cmd msg
createPost req =
    put
        { url = url req.mode "/post/private"
        , expect = Http.expectJson req.msg Post.fullDecoder
        , body = Http.jsonBody <| Post.encodeFreshFull req.resource
        }


updatePost : UpdateOne (Post Core Full) msg -> Cmd msg
updatePost req =
    post
        { url = url req.mode "/post/private"
        , expect = Http.expectJson req.msg Post.fullDecoder
        , body = Http.jsonBody <| Post.encodeFull req.resource
        }


deletePost : DeleteOne msg -> Cmd msg
deletePost req =
    delete
        { url = url req.mode <| UUID.toPath "/post/owner" req.uuid
        , expect = Http.expectWhatever req.msg
        }


getAuthor : GetOne Author msg -> Cmd msg
getAuthor req =
    let
        path =
            UUID.toPath "/author/public/" req.uuid
    in
    get
        { url = url req.mode path
        , expect = Http.expectJson req.msg Author.decoder
        }


getAuthors : GetMany Author msg -> Cmd msg
getAuthors req =
    getPage "author" Author.decoder req


getTag : GetOne Tag msg -> Cmd msg
getTag req =
    let
        path =
            UUID.toPath "/tag/public/" req.uuid
    in
    get
        { url = url req.mode path
        , expect = Http.expectJson req.msg Tag.decoder
        }


getTags : GetMany Tag msg -> Cmd msg
getTags req =
    getPage "tag" Tag.decoder req


login : Login msg -> Cmd msg
login req =
    let
        path =
            "/login/"
    in
    post
        { url = url req.mode path
        , expect = Http.expectJson req.msg Data.Login.decodeResponse
        , body = Http.jsonBody <| Data.Login.encodeRequest <| Data.Login.Request req.username req.password
        }


logout : Logout msg -> Cmd msg
logout req =
    post
        { url = url req.mode "/logout/"
        , expect = Http.expectWhatever req.msg
        , body = Http.emptyBody
        }


toOffset : List a -> Int
toOffset list =
    List.length list // paginationCount


finished : List a -> Bool
finished list =
    modBy paginationCount (List.length list) == 0



{- Constructors -}


url : Mode -> String -> Url
url mode path =
    Url <| Internals mode path



{- Util -}


urlToString : Url -> String
urlToString (Url internals) =
    let
        host =
            case internals.mode of
                Development ->
                    "http://localhost:9081"

                Production ->
                    "https://api.parasrah.com:9091"

        path =
            internals.path
                |> ensureRightSlash
                |> ensureLeftSlash
    in
    host ++ path


paginationCount : Int
paginationCount =
    10


ensureRightSlash : String -> String
ensureRightSlash path =
    let
        containsQuery =
            String.contains "?" path

        missingSlash =
            if containsQuery then
                path
                    |> String.contains "/?"
                    |> not

            else
                path
                    |> String.left 1
                    |> (/=) "/"
    in
    if missingSlash then
        if containsQuery then
            path
                |> String.replace "?" "/?"

        else
            path ++ "/"

    else
        path


ensureLeftSlash : String -> String
ensureLeftSlash path =
    case String.left 1 path of
        "/" ->
            path

        _ ->
            "/" ++ path


urlToHeaders : Url -> List Header
urlToHeaders (Url internals) =
    case internals.mode of
        Development ->
            -- [ Http.header "Referrer-Policy" "origin-when-cross-origin" ]
            []

        Production ->
            []


get : { expect : Expect msg, url : Url } -> Cmd msg
get args =
    Http.riskyRequest
        { method = "GET"
        , headers = urlToHeaders args.url
        , url = urlToString args.url
        , body = Http.emptyBody
        , expect = args.expect
        , timeout = Nothing
        , tracker = Nothing
        }


getPage : String -> Decoder r -> GetMany r msg -> Cmd msg
getPage resourceRoute decoder req =
    let
        access =
            case req.user of
                Just _ ->
                    "private/"

                Nothing ->
                    "public/"

        path =
            String.join ""
                [ "/"
                , resourceRoute
                , "/"
                , access
                , "?count="
                , String.fromInt paginationCount
                , "&start="
                , String.fromInt req.offset
                ]
    in
    get
        { url = url req.mode path
        , expect = Http.expectJson req.msg (Decode.list decoder)
        }


put : { expect : Expect msg, body : Body, url : Url } -> Cmd msg
put args =
    Http.riskyRequest
        { method = "PUT"
        , headers = urlToHeaders args.url
        , url = urlToString args.url
        , body = args.body
        , expect = args.expect
        , timeout = Nothing
        , tracker = Nothing
        }


post : { expect : Expect msg, body : Body, url : Url } -> Cmd msg
post args =
    Http.riskyRequest
        { method = "POST"
        , headers = urlToHeaders args.url
        , url = urlToString args.url
        , body = args.body
        , expect = args.expect
        , timeout = Nothing
        , tracker = Nothing
        }


delete : { expect : Expect msg, url : Url } -> Cmd msg
delete args =
    Http.riskyRequest
        { method = "DELETE"
        , headers = urlToHeaders args.url
        , url = urlToString args.url
        , body = Http.emptyBody
        , expect = args.expect
        , timeout = Nothing
        , tracker = Nothing
        }
