module Data.Password exposing (Password, encode, create)


import Json.Encode as Encode exposing (Value)


{- Model -}


type Password =
    Password String



{- Constructors -}


create : String -> Password
create str =
    Password str


{- JSON -}


encode : Password -> Value
encode (Password password) =
    Encode.string password
