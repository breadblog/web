module Endpoint exposing (Endpoint, create, decoder, delete, discover, get, update)

import Data.Mode as Mode exposing (Env(..), Mode(..))
import Http exposing (Body, Header)
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Task exposing (Task)
import Url exposing (Url)


type Endpoint
    = Discover
    | Dynamic Url


type alias Endpoints =
    { posts : Endpoint
    , tags : Endpoint
    , authors : Endpoint
    }


discover : Mode -> Task Http.Error Endpoints
discover mode =
    Http.riskyTask
        { method = "GET"
        , body = Http.emptyBody
        , url = toUrl mode Discover |> Url.toString
        , headers = headers mode
        , timeout = Nothing
        , resolver = Http.stringResolver <| handleJsonResponse <| discoverDecoder mode
        }


discoverDecoder : Mode -> Decoder Endpoints
discoverDecoder mode =
    Json.Decode.succeed Endpoints
        |> required "posts" decoder
        |> required "tags" decoder
        |> required "authors" decoder


decoder : Decoder Endpoint
decoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\href ->
                case Url.fromString href of
                    Just url ->
                        Json.Decode.succeed (Dynamic url)

                    Nothing ->
                        Json.Decode.fail <| "invalid url: " ++ href
            )


toUrl : Mode -> Endpoint -> Url
toUrl mode endpoint =
    case endpoint of
        Discover ->
            Mode.toUrl mode

        Dynamic url ->
            url


headers : Mode -> List Header
headers mode =
    case Mode.toEnv mode of
        Dev ->
            -- [ Http.header "Referrer-Policy" "origin-when-cross-origin" ]
            []

        Prod ->
            []



-- Helpers --


get : { decoder : Decoder a, endpoint : Endpoint, mode : Mode } -> Task Http.Error a
get args =
    Http.riskyTask
        { method = "GET"
        , headers = headers args.mode
        , url = toUrl args.mode args.endpoint |> Url.toString
        , body = Http.emptyBody
        , resolver = Http.stringResolver <| handleJsonResponse <| args.decoder
        , timeout = Nothing
        }


update : { decoder : Decoder a, body : Body, endpoint : Endpoint, mode : Mode } -> Task Http.Error a
update args =
    Http.riskyTask
        { method = "PUT"
        , headers = headers args.mode
        , url = toUrl args.mode args.endpoint |> Url.toString
        , body = args.body
        , resolver = Http.stringResolver <| handleJsonResponse <| args.decoder
        , timeout = Nothing
        }


create : { decoder : Decoder a, body : Body, endpoint : Endpoint, mode : Mode } -> Task Http.Error a
create args =
    Http.riskyTask
        { method = "POST"
        , headers = headers args.mode
        , url = toUrl args.mode args.endpoint |> Url.toString
        , body = args.body
        , resolver = Http.stringResolver <| handleJsonResponse <| args.decoder
        , timeout = Nothing
        }


delete : { decoder : Decoder e, endpoint : Endpoint, mode : Mode } -> Task Http.Error e
delete args =
    Http.riskyTask
        { method = "DELETE"
        , headers = headers args.mode
        , url = toUrl args.mode args.endpoint |> Url.toString
        , body = Http.emptyBody
        , timeout = Nothing
        , resolver = Http.stringResolver <| handleJsonResponse <| args.decoder
        }


handleJsonResponse : Decoder a -> Http.Response String -> Result Http.Error a
handleJsonResponse aDecoder response =
    case response of
        Http.BadUrl_ url ->
            Err (Http.BadUrl url)

        Http.Timeout_ ->
            Err Http.Timeout

        Http.BadStatus_ { statusCode } _ ->
            Err (Http.BadStatus statusCode)

        Http.NetworkError_ ->
            Err Http.NetworkError

        Http.GoodStatus_ _ body ->
            case Json.Decode.decodeString aDecoder body of
                Err _ ->
                    Err (Http.BadBody body)

                Ok result ->
                    Ok result
