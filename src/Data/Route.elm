module Data.Route exposing (Route(..), fromUrl, toClass, toName, toPath)

import Data.UUID as UUID exposing (UUID)
import Json.Decode as Decode
import Url exposing (Url)
import Url.Builder exposing (relative)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, parse, s, string, top)


type Route
    = NotFound
    | Home
    | Post (Maybe UUID)
    | About
    | Donate
    | Changelog
    | Login



-- Parser


urlParser : Parser (Route -> a) a
urlParser =
    oneOf
        -- Common
        [ Parser.map Home top
        , Parser.map Login (s "login")

        -- Posts
        , Parser.map (Post Nothing) (s "post" </> s "create")
        , Parser.map (\uuid -> Post (Just uuid)) (s "post" </> UUID.urlParser)

        -- Info
        , Parser.map About (s "about")
        , Parser.map Donate (s "donate")
        , Parser.map Changelog (s "changelog")
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

        Login ->
            "Login"

        About ->
            "About"

        Donate ->
            "Donate"

        Post slug ->
            "Post"

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

        Login ->
            relative [ "/login" ] []

        Post maybePostUUID ->
            case maybePostUUID of
                Just postUUID ->
                    relative [ UUID.toPath "/post" postUUID ] []

                Nothing ->
                    relative [ "/post/create" ] []

        About ->
            relative [ "/about" ] []

        Donate ->
            relative [ "/donate" ] []

        Changelog ->
            relative [ "/changelog" ] []

        NotFound ->
            relative [ "/404" ] []
