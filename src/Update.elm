module Update exposing (Output)


import Message exposing (Compound)
import Data.General exposing (General)


type alias Output msg model =
    { model : model
    , cmd : Cmd (Compound msg)
    , general : General
    }
