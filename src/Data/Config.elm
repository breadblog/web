module Data.Config exposing (Config)


import Api exposing (Host)


type alias Config =
    { host : Host
    }
