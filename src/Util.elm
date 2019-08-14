module Util exposing (joinLeftWith)

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


groupBy : (a -> a -> String) -> List a -> List (List a)
groupBy group list =
    list
        |> List.map (\a -> { value = a, group = group a })
        |> List.groupBy ()



{-
   [ 1, 3, 9, 2 ]

   [ { v: 1, s: "a" }
   , { v: 3, s: "b" }
   , { v: 9, s: "b" }
   , { v: 2, s: "a" }
   ]

   [ [ 1, 2 ]
   , [ 3, 9 ]
   ]
-}
