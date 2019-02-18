port module Port exposing (..)


import Json.Encode as E
import Message exposing Msg



port cache : E.Value -> Cmd Msg
