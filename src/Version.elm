module Version exposing (current)

import Data.Version exposing (Version)


current : Maybe Version
current =
    Data.Version.fromString "0.0.28"
