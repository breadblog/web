module Update exposing (Output)

import Data.General exposing (General)
import Message exposing (Compound)


type alias Output msg model =
    { model : model
    , cmd : Cmd (Compound msg)
    , general : General
    }
