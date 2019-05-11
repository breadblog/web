module Data.Route exposing (ProblemPage(..), Route(..), fromUrl, toClass, toName, toPath)

import Data.Slug as Slug exposing (Slug)
import Json.Decode as Decode
import Url exposing (Url)
import Url.Builder exposing (relative)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, parse, s, string, top)


type Route
    = NotFound
    | Home
    | Post Slug
    | Profile
    | About
    | Donate
    | Changelog


type ProblemPage
    = None
    | CorruptCache Decode.Error
    | InvalidVersion



-- Parser


urlParser : Parser (Route -> a) a
urlParser =
    oneOf
        -- Common
        [ Parser.map Home top

        -- Posts
        , Parser.map Post (s "post" </> Slug.urlParser)

        -- Info
        , Parser.map About (s "about")
        , Parser.map Donate (s "donate")
        , Parser.map Changelog (s "changelog")

        -- ErrorPages
        ]



-- Util


fromUrl : Url -> Route
fromUrl url =
    url
        |> Url.toString
        |> fromString


toClass : Route -> String
toClass route =
    case route of
        NotFound ->
            "not-found"

        _ ->
            route
                |> toName
                |> String.replace " " "-"
                |> String.toLower


toTitle : Route -> String
toTitle route =
    let
        routeName =
            toName route
    in
    case route of
        Home ->
            titlePrefix

        _ ->
            titlePrefix ++ " | " ++ routeName


toName : Route -> String
toName route =
    case route of
        Home ->
            "Home"

        About ->
            "About"

        Donate ->
            "Donate"

        Post slug ->
            "Post" ++ Slug.toString slug

        Profile ->
            "Profile"

        Changelog ->
            "Changelog"

        NotFound ->
            "404"


titlePrefix : String
titlePrefix =
    "Bits & Bites"


fromString : String -> Route
fromString str =
    case Url.fromString str of
        Nothing ->
            NotFound

        Just url ->
            Maybe.withDefault NotFound <|
                parse urlParser url


toPath : Route -> String
toPath route =
    case route of
        Home ->
            relative [ "/" ] []

        Post slug ->
            relative [ "/post", Slug.toString slug ] []

        Profile ->
            relative [ "/profile" ] []

        -- Login ->
        --     relative [ "/login" ] []
        About ->
            relative [ "/about" ] []

        Donate ->
            relative [ "/donate" ] []

        Changelog ->
            relative [ "/changelog" ] []

        NotFound ->
            relative [ "/404" ] []
