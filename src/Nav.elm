module Nav exposing (routeParser, routeToClass, routeToName, routeToPath, routeToTitle, urlToRoute)

import Data.Route as Route exposing (ProblemPage(..), Route(..))
import Data.Slug as Slug exposing (Slug(..))
import Url exposing (Url)
import Url.Builder exposing (absolute)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, parse, s, string, top)


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        -- Common
        [ Parser.map Home top

        -- Bits
        , Parser.map Post (s "post" </> Slug.urlParser)

        -- ErrorPages
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
        Home ->
            "Fork"

        Post slug ->
            "Post" ++ Slug.toString slug

        Profile ->
            "Profile"

        Login ->
            "Login"

        NotFound ->
            "404"

        Problem problem ->
            -- TODO: Replace me
            "Problem"


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


routeToPath : Route -> String
routeToPath route =
    case route of
        Home ->
            absolute [] []

        Post slug ->
            absolute [ "post", Slug.toString slug ] []

        Profile ->
            absolute [ "/profile" ] []

        Login ->
            absolute [ "/login" ] []

        NotFound ->
            absolute [ "/404" ] []

        Problem problem ->
            case problem of
                CorruptCache ->
                    absolute [ "/error", "corruptCache" ] []

                InvalidVersion ->
                    absolute [ "/error", "invalidVersion" ] []


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
