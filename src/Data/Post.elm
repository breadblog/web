module Data.Post exposing (Post)


import Time


type alias Post =
    { title : String
    , content : String
    , author : String
    , date : Time.Posix
    }
