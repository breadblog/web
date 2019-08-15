module Util exposing (includesBy, joinLeftWith)

import List.Extra



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
            case List.Extra.find (compare aEl) b of
                Just bEl ->
                    transform aEl bEl

                Nothing ->
                    aEl
        )
        a


includesBy : (b -> a -> Bool) -> b -> List a -> Bool
includesBy predicate el list =
    case List.Extra.find (predicate el) list of
        Just _ ->
            True

        Nothing ->
            False
