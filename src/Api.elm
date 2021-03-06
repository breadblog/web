module Api exposing (Url, count, delete, get, post, put, url)

import Constants
import Data.Mode exposing (Mode(..))
import Http exposing (Body, Expect, Header)


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
            Constants.apiUrl internals.mode

        path =
            internals.path
                |> ensureRightSlash
                |> ensureLeftSlash
    in
    host ++ path


count : Int
count =
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
