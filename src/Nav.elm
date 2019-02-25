module Nav exposing (routeParser, routeToClass, routeToName, routeToTitle, urlToRoute)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, parse, s, string, top)
import Model exposing (Route(..), Slug(..), ErrorPage(..))


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        -- Common
        [ Parser.map Fork top

        -- Bits
        , Parser.map DarkHome (s "bits")
        , Parser.map DarkPost (s "bits" </> s "post" </> slugUrlParser)

        -- Bites
        , Parser.map QnHome (s "bites")
        , Parser.map QnPost (s "bites" </> s "post" </> slugUrlParser)

        -- ErrorPages
        ]


slugUrlParser : Parser (Slug -> a) a
slugUrlParser =
    Parser.custom "SLUG" (\str -> Just (Slug str))


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
        Fork ->
            "Fork"

        DarkHome ->
            "Parasrah"

        QnHome ->
            "Qnbst"

        About ->
            "About"

        DarkPost slug ->
            "Parasrah Post"

        QnPost slug ->
            "Qnbst Post"

        NotFound ->
            "404"

        Error e ->
            case e of
                CorruptCache _ ->
                    "Corrupt Cache"



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
