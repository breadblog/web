module Api exposing (Url, Host, url, get, put, delete, post, hostFromMode)


import Http exposing (Expect)
import Json.Encode exposing (Value)
import Data.Mode exposing (Mode(..))


type Url
    = Url String


type Host
    = Host String


url : Host -> String -> Url
url (Host host) path =
    Url <| host ++ path


hostFromMode : Mode -> Host
hostFromMode mode =
    case mode of
        Development ->
            Host "http://127.0.0.1:9081/"

        Production ->
            Host "https://api.parasrah.com:9091/"



get : { expect : Expect msg, url : Url } -> Cmd msg
get args =
    let
        (Url url_) =
            args.url

    in
    Http.request
        { method = "GET"
        , headers = []
        , url = url_
        , body = Http.emptyBody
        , expect = args.expect
        , timeout = Nothing
        , tracker = Nothing
        }


put : { expect : Expect msg, body : Value, url : Url } -> Cmd msg
put args =
    let
        (Url url_) =
            args.url

    in
    Http.request
        { method = "PUT"
        , headers = []
        , url = url_
        , body = Http.jsonBody args.body
        , expect = args.expect
        , timeout = Nothing
        , tracker = Nothing
        }


post : { expect : Expect msg, body : Value, url : Url } -> Cmd msg
post args =
    let
        (Url url_) =
            args.url

    in
    Http.request
        { method = "POST"
        , headers = []
        , url = url_
        , body = Http.jsonBody args.body
        , expect = args.expect
        , timeout = Nothing
        , tracker = Nothing
        }


delete : { expect : Expect msg, url : Url } -> Cmd msg
delete args =
    let
        (Url url_) =
            args.url

    in
    Http.request
        { method = "DELETE"
        , headers = []
        , url = url_
        , body = Http.emptyBody
        , expect = args.expect
        , timeout = Nothing
        , tracker = Nothing
        }
