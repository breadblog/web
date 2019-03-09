module Data.Route exposing (Route(..), ProblemPage(..))


import Data.Slug exposing (Slug)
import Data.ProblemInfo exposing (ProblemInfo)


type Route
    = NotFound
    | Home
    | Post Slug
    | Profile
    | Login
    | Problem ProblemPage


type ProblemPage
    = CorruptCache String
