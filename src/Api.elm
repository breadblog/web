module Api exposing (Url, count, delete, get, post, put, url)

import Data.Mode exposing (Mode(..))
import Http exposing (Expect, Header)
import Json.Encode exposing (Value)


type Url
    = Url Internals


type alias Internals =
    { mode : Mode
    , path : String
    }


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


count : Int
count =
    10



-- FIXME: very simplistic, will not work for urls containing \?


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
    Http.request
        { method = "GET"
        , headers = urlToHeaders args.url
        , url = urlToString args.url
        , body = Http.emptyBody
        , expect = args.expect
        , timeout = Nothing
        , tracker = Nothing
        }


put : { expect : Expect msg, body : Value, url : Url } -> Cmd msg
put args =
    Http.request
        { method = "PUT"
        , headers = urlToHeaders args.url
        , url = urlToString args.url
        , body = Http.jsonBody args.body
        , expect = args.expect
        , timeout = Nothing
        , tracker = Nothing
        }


post : { expect : Expect msg, body : Value, url : Url } -> Cmd msg
post args =
    Http.request
        { method = "POST"
        , headers = urlToHeaders args.url
        , url = urlToString args.url
        , body = Http.jsonBody args.body
        , expect = args.expect
        , timeout = Nothing
        , tracker = Nothing
        }


delete : { expect : Expect msg, url : Url } -> Cmd msg
delete args =
    Http.request
        { method = "DELETE"
        , headers = urlToHeaders args.url
        , url = urlToString args.url
        , body = Http.emptyBody
        , expect = args.expect
        , timeout = Nothing
        , tracker = Nothing
        }
