module Nav exposing (routeParser, routeToClass, routeToName, routeToTitle, urlToRoute)

import Model exposing (ErrorPage(..), Route(..), Slug(..))
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, parse, s, string, top)


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        -- Common
        [ Parser.map Home top

        -- Posts
        , Parser.map ReadPost (s "post" </> slugUrlParser)

        -- Info
        , Parser.map About (s "about")

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
        Home ->
            "Fork"

        About ->
            "About"

        ReadPost slug ->
            "Post"

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
        Home ->
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
