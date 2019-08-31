module Data.Password exposing (Password, empty, encode, onInput)

import Html.Styled exposing (Attribute)
import Html.Styled.Events as Events
import Json.Encode as Encode exposing (Value)



{- Model -}


type Password
    = Password String



{- Constructors -}


empty : Password
empty =
    Password ""



{- Util -}


onInput : (Password -> msg) -> Attribute msg
onInput createMsg =
    Events.onInput <| Password >> createMsg



{- JSON -}


encode : Password -> Value
encode (Password password) =
    Encode.string password
