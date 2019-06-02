module Data.Problem exposing (Problem, Description(..), create)


import Http
import Json.Decode
import Data.Markdown exposing (Markdown)


type Problem handler
    = Problem (Internals handler)


type Description
    = JsonError Json.Decode.Error
    | MarkdownError Markdown
    | HttpError Http.Error


type alias Internals handler =
    -- title for the problem
    { title : String
    -- a description of the problem (in markdown)
    , description : Description
    -- a possible message to trigger, handling the problem
    , reaction : Maybe handler
    }


{- Accessors -}

title : Problem e -> String
title (Problem internals) =
    internals.title


description : Problem e -> Description
description (Problem internals) =
    internals.description


reaction : Problem e -> Maybe e
reaction (Problem internals) =
    internals.reaction


{- Constructors -}

create : String -> Description -> Maybe e -> Problem e
create title_ desc handler_ =
    Problem <|
        Internals title_ desc handler_
