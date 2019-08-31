module Data.Search exposing (Create, Source, category, description, name, onClick, search, source, toInternals)

import Html.Styled exposing (Attribute)
import Html.Styled.Events as Events
import Simple.Fuzzy as Fuzzy



{- Model -}


type Source msg
    = Source (Internals msg)


type alias Internals msg =
    { category : String
    , onClick : msg
    , name : String
    , values : List String
    , description : String
    }


type alias Create msg =
    Internals msg



{- Constructors -}


source : Create msg -> Source msg
source internals =
    let
        breakpoint =
            50

        updatedDesc =
            if String.length internals.description > breakpoint then
                internals.description
                    |> String.left breakpoint
                    |> String.words
                    |> List.reverse
                    |> List.drop 1
                    |> List.reverse
                    |> String.join " "

            else
                internals.description
    in
    Source
        { internals
            | description = updatedDesc
        }



{- Accessors -}


toInternals : Source m -> Internals m
toInternals (Source internals) =
    internals


category : Source m -> String
category =
    toInternals >> .category


onClick : Source msg -> Attribute msg
onClick =
    toInternals >> .onClick >> Events.onClick


name : Source m -> String
name =
    toInternals >> .name


description : Source m -> String
description =
    toInternals >> .description



{- Util -}


search : List (Source m) -> String -> List (Source m)
search sources searchTerm =
    List.filter (searchPredicate searchTerm) sources


searchPredicate : String -> Source m -> Bool
searchPredicate searchTerm (Source internals) =
    List.any (\v -> String.contains searchTerm v) internals.values
