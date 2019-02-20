module Nav exposing (Route(..), routeParser, routeToName, routeToTitle, routeToClass, urlToRoute)


import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, parse, s, string, top)


type Route
    = Fork
    | BitsHome
    | BitesHome
    | About
    | NotFound


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        -- Common
        [ Parser.map Fork top

        -- Bits
        , Parser.map BitsHome (s "bits")

        -- Bites
        , Parser.map BitesHome (s "bites")
        ]


toRoute : String -> Route
toRoute str =
    case Url.fromString str of
        Nothing ->
            NotFound

        Just url ->
            Maybe.withDefault NotFound <|
                parse routeParser url


routeToName : Route -> String
routeToName route =
    case route of
        Fork -> "Fork"

        BitsHome -> "Bits"

        BitesHome -> "Bites"

        About -> "About"

        NotFound -> "404"


routeToTitle : Route -> String
routeToTitle route =
    let
        routeName =
            routeToName route

    in
        case route of
            Fork ->
                titlePrefix

            _ ->
                titlePrefix ++ " | " ++ routeName


titlePrefix : String
titlePrefix =
    "Bits & Bites"


urlToRoute : Url -> Route
urlToRoute url =
    url
    |> Url.toString
    |> toRoute


routeToClass : Route -> String
routeToClass route =
    case route of
        NotFound ->
            "not-found"

        _ ->
            route
                |> routeToName
                |> String.replace " " "-"
                |> String.toLower
