module Api exposing (Url, getAuthors, getPostPreviews, getTags, login, logout, onUpdate)

import Data.Author as Author exposing (Author)
import Data.Login as Login
import Data.Mode exposing (Mode(..))
import Data.Password as Password exposing (Password)
import Data.Post as Post exposing (Core, Post, Preview)
import Data.Tag as Tag exposing (Tag)
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



{- Public API -}


type alias MsgConstructor resource msg =
    Result Http.Error resource -> msg


getTags : Mode -> MsgConstructor (List Tag) msg -> Int -> Cmd msg
getTags =
    getList "/tag/public/" (Decode.list Tag.decoder)


getAuthors : Mode -> MsgConstructor (List Author) msg -> Int -> Cmd msg
getAuthors =
    getList "/author/public" (Decode.list Author.decoder)


getPostPreviews : Mode -> MsgConstructor (List (Post Core Preview)) msg -> Int -> Cmd msg
getPostPreviews =
    getList "/post/public/" <|
        Decode.list <|
            Post.previewDecoder <|
                Just False


logout : Mode -> MsgConstructor () msg -> Cmd msg
logout mode createMsg =
    post
        { url = url mode "/logout/"
        , expect = Http.expectWhatever createMsg
        , body = Http.emptyBody
        }


login : Mode -> MsgConstructor Login.Response msg -> String -> Password -> Cmd msg
login mode createMsg username password =
    post
        { url = url mode "/login"
        , expect = Http.expectJson createMsg Login.responseDecoder
        , body = Http.jsonBody <| Login.encodeRequest <| Login.Request username password
        }


type alias WithResource model resource =
    { model : model
    , resource : resource
    , mode : Mode
    }


type alias OnUpdateParams resource msg output =
    { getMore : Int -> Cmd msg
    , onComplete : List resource -> output
    , onLoading : List resource -> Cmd msg -> output
    , oldResources : List resource
    , newResources : List resource
    }


onUpdate : OnUpdateParams resource msg output -> output
onUpdate params =
    let
        aggregateResources =
            params.oldResources ++ params.newResources
    in
    if List.length params.newResources == paginationSize then
        let
            page =
                (List.length aggregateResources // paginationSize) + 1

            cmd =
                params.getMore page
        in
        params.onLoading aggregateResources cmd

    else
        params.onComplete aggregateResources



{- Helpers -}


getList : String -> Decoder r -> Mode -> MsgConstructor r msg -> Int -> Cmd msg
getList pathPrefix decoder mode createMsg page =
    let
        start =
            page * paginationSize

        path =
            String.join ""
                [ pathPrefix
                , "?count="
                , String.fromInt paginationSize
                , "&start="
                , String.fromInt start
                ]
    in
    get
        { url = url mode path
        , expect = Http.expectJson createMsg decoder
        }


paginationSize : Int
paginationSize =
    10


url : Mode -> String -> Url
url mode path =
    Url <| Internals mode path


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
