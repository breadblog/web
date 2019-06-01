module Data.Problem exposing (Problem)


import Data.Markdown exposing (Markdown)


type Problem handler
    = Problem (Internals handler)


type alias Internals handler =
    -- title for the problem
    { title : String
    -- a description of the problem (in markdown)
    , description : Markdown
    -- a possible message to trigger, handling the problem
    , reaction : Maybe handler
    }


{- Accessors -}

title : Problem e -> String
title (Problem internals) =
    internals.title


description : Problem e -> Markdown
description (Problem internals) =
    internals.description


reaction : Problem e -> Maybe e
reaction (Problem internals) =
    internals.reaction


{- Constructors -}

create : String -> Markdown -> Maybe e -> Problem e
create title_ desc handler_ =
    Problem <|
        Internals title_ desc handler_
