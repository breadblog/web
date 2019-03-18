module Data.Search exposing (Result, search)


import Simple.Fuzzy as Fuzzy
import Data.Source exposing (Source)


type alias Result =
    { value : String
    }


search : List Source -> String -> List Result
search sources searchTerm =
    []
