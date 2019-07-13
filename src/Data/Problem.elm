module Data.Problem exposing (Description(..), Handler, Problem, create, createHandler, description, encode, handler, handlerMsg, handlerText, map, title)

import Data.Markdown as Markdown exposing (Markdown)
import Html.Styled exposing (Attribute, Html)
import Html.Styled.Events
import Http exposing (Error(..))
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type Problem msg
    = Problem (Internals msg)


type Description
    = JsonError Decode.Error
    | MarkdownError Markdown
    | HttpError Http.Error


type alias Internals msg =
    -- title for the problem
    { title : String

    -- a description of the problem (in markdown)
    , description : Description

    -- a possible message to trigger, handling the problem
    , handler : Maybe (Handler msg)
    }


type Handler msg
    = Handler (IHandler msg)


type alias IHandler msg =
    { label : String
    , msg : msg
    }



{- Accessors -}


title : Problem e -> String
title (Problem internals) =
    internals.title


description : Problem e -> Description
description (Problem internals) =
    internals.description


handlerMsg : Handler msg -> msg
handlerMsg (Handler internals) =
    internals.msg


handlerText : Handler msg -> Html e
handlerText (Handler internals) =
    Html.Styled.text internals.label


handler : Problem msg -> Maybe (Handler msg)
handler (Problem internals) =
    internals.handler



{- Constructors -}


create : String -> Description -> Maybe (Handler msg) -> Problem msg
create title_ desc handler_ =
    Problem <|
        Internals title_ desc handler_


createHandler : String -> msg -> Handler msg
createHandler label msg =
    Handler <| IHandler label msg



{- Util -}


map : (a -> b) -> List (Problem a) -> List (Problem b)
map transform problems =
    List.map
        (\(Problem problem) ->
            let
                handler_ =
                    case problem.handler of
                        Nothing ->
                            Nothing

                        Just (Handler h) ->
                            Just <|
                                Handler
                                    { label = h.label
                                    , msg = transform h.msg
                                    }
            in
            { title = problem.title
            , description = problem.description
            , handler = handler_
            }
                |> Problem
        )
        problems


isBodySafe : String -> Bool
isBodySafe str =
    let
        checks =
            [ String.contains "password"
            , String.contains "Password"
            , String.contains "hash"
            , String.contains "Hash"
            ]
    in
    not <| List.any (\c -> c str) checks



{- JSON -}


encode : Problem msg -> Value
encode (Problem internals) =
    Encode.object
        [ ( "title", Encode.string internals.title )
        , ( "description", encodeDesc internals.description )
        ]


encodeDesc : Description -> Value
encodeDesc desc =
    case desc of
        MarkdownError err ->
            Markdown.encode err

        JsonError err ->
            Encode.string <| Decode.errorToString err

        HttpError err ->
            case err of
                BadUrl str ->
                    Encode.string <| "bad url: " ++ str

                Timeout ->
                    Encode.string "request timeout"

                NetworkError ->
                    Encode.string "network error"

                BadStatus int ->
                    Encode.string <| "bad status: " ++ String.fromInt int

                BadBody str ->
                    if isBodySafe str then
                        Encode.string <| "bad body: " ++ str

                    else
                        Encode.string "bad body (unsafe contents)"
