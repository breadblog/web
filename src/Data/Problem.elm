module Data.Problem exposing (Description(..), Handler, Problem, create, description, map, title, handler, onClick, handlerText)

import Data.Markdown exposing (Markdown)
import Http
import Json.Decode
import Html.Styled.Events
import Html.Styled exposing (Attribute, Html)


type Problem msg
    = Problem (Internals msg)


type Description
    = JsonError Json.Decode.Error
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


type Handler msg =
    Handler (IHandler msg)


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


onClick : Handler msg -> Attribute msg
onClick (Handler internals) =
    Html.Styled.Events.onClick internals.msg


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
                            Just <| Handler
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
