module Data.Search exposing (Source, Result, search, source, value, onClick, context)


import Simple.Fuzzy as Fuzzy


-- Model --

type Source msg =
    Source (ISource msg)


type alias ISource msg =
    { values: List String
    , context : String
    , onClick : msg
    }


{-
    Result

    The only way to receive a result is to call the "search" function.
    should not be constructed outside this module
-}


type Result msg =
    Result (IResult msg)


type alias IResult msg =
    { value : String
    , context : String
    , onClick : msg
    }


-- Constructors


source : List String -> String -> msg -> Source msg
source values context_ msg =
    Source <| ISource values context_ msg


-- Accessors


value : Result msg -> String
value (Result r) =
    r.value


onClick : Result msg -> msg
onClick (Result r) =
    r.onClick


context : Result msg -> String
context (Result r) =
    r.context


-- Util



-- TODO: room for optimization here (lots of copied information in context, onClick)

search : List (Source msg) -> String -> List (Result msg)
search sources searchTerm =
    let
        values =
            sources
                |> (List.map (\(Source s) ->
                    List.map (\v ->
                        IResult v s.context s.onClick
                    )
                    s.values
                ))
                |> List.concat

        filteredValues =
            Fuzzy.filter .value searchTerm values

        topValues =
            List.take 10 filteredValues
    in
        List.map Result topValues
