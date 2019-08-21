module Data.Search exposing (SearchResult, Source, context, onClick, search, source, value)

import Simple.Fuzzy as Fuzzy



-- Model --


type Source msg
    = Source (ISource msg)


type alias ISource msg =
    { values : List String
    , context : String
    , onClick : msg
    }



{-
   SearchResult

   The only way to receive a result is to call the "search" function.
   should not be constructed outside this module
-}


type SearchResult msg
    = SearchResult (IResult msg)


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


value : SearchResult msg -> String
value (SearchResult r) =
    r.value


onClick : SearchResult msg -> msg
onClick (SearchResult r) =
    r.onClick


context : SearchResult msg -> String
context (SearchResult r) =
    r.context



-- Util


search : List (Source msg) -> String -> List (SearchResult msg)
search sources searchTerm =
    let
        values =
            sources
                |> List.map
                    (\(Source s) ->
                        List.map
                            (\v ->
                                IResult v s.context s.onClick
                            )
                            s.values
                    )
                |> List.concat

        filteredValues =
            Fuzzy.filter .value searchTerm values

        topValues =
            List.take 10 filteredValues
    in
    List.map SearchResult topValues
