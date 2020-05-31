-- TODO: this should be generated from package.json
module Version exposing (current)

import Data.Version exposing (Version)


current : Maybe Version
current =
    Data.Version.fromString "0.0.39"
