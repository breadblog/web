module Data.Route exposing (ProblemPage(..), Route(..))

import Data.Slug exposing (Slug)


type Route
    = NotFound
    | Home
    | Post Slug
    | Profile
    | Login
    | Problem ProblemPage


type ProblemPage
    = CorruptCache
    | InvalidVersion
