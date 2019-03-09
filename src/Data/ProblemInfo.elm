module Data.ProblemInfo exposing (ProblemInfo)


type ProblemInfo =
    ProblemInfo Internals


type alias Internals =
    { title : String
    , description : String
    }


-- READONLY


title : ProblemInfo -> String
title (ProblemInfo info) =
    info.title


-- READONLY


description : ProblemInfo -> String
description (ProblemInfo info) =
    info.description


-- Utils


create : Internals -> ProblemInfo
create internals =
    ProblemInfo internals
