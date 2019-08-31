module Data.Username exposing (Username, decoder, empty, encode, onInput, toString)

import Html.Styled as Html exposing (Attribute, Html)
import Html.Styled.Events as Events
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)



{- Model -}


type Username
    = Username String



{- Constructors -}


empty : Username
empty =
    Username ""



{- Util -}


onInput : (Username -> msg) -> Attribute msg
onInput createMsg =
    Events.onInput <| Username >> createMsg


text : Username -> Html msg
text (Username username) =
    Html.text username


toString : Username -> String
toString (Username str) =
    str



{- Json -}


decoder : Decoder Username
decoder =
    Decode.string
        |> Decode.andThen
            (\str -> Decode.succeed (Username str))


encode : Username -> Value
encode (Username str) =
    Encode.string str
