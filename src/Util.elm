module Util exposing (find, joinLeftWith)

{--
    Join two lists

    If the compare function produces a match, the result of
    transform will be emitted to list. If no match is found,
    the element from the left list will be emitted
--}


joinLeftWith : (t -> t -> t) -> (t -> t -> Bool) -> List t -> List t -> List t
joinLeftWith transform compare a b =
    List.map
        (\aEl ->
            case find (compare aEl) b of
                Just bEl ->
                    transform aEl bEl

                Nothing ->
                    aEl
        )
        a


find : (t -> Bool) -> List t -> Maybe t
find predicate list =
    list
        |> List.filter predicate
        |> List.head
