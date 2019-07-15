module Data.Route exposing (PostType(..), Route(..), fromUrl, toClass, toName, toPath)

import Data.UUID as UUID exposing (UUID)
import Json.Decode as Decode
import Url exposing (Url)
import Url.Builder exposing (relative)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, parse, s, string, top)


type Route
    = NotFound
    | Home
    | Post PostType
    | About
    | Donate
    | Changelog
    | Login


type PostType
    = Ready UUID
    | Create
    | Edit UUID
    | Delete UUID



-- Parser


urlParser : Parser (Route -> a) a
urlParser =
    oneOf
        -- Common
        [ Parser.map Home top
        , Parser.map Login (s "login")

        -- Posts
        , Parser.map (Post Create) (s "post" </> s "create")
        , Parser.map (Post << Ready) (s "post" </> UUID.urlParser)
        , Parser.map (Post << Edit) (s "post" </> s "edit" </> UUID.urlParser)
        , Parser.map (Post << Delete) (s "post" </> s "delete" </> UUID.urlParser)

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

        Post postType ->
            case postType of
                Create ->
                    "➕ Post"

                Delete _ ->
                    "🗑️ Post"

                Edit _ ->
                    "✏️  Post"

                Ready _ ->
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

        Post postType ->
            case postType of
                Create ->
                    relative [ "/post/create" ] []

                Ready postUUID ->
                    relative [ UUID.toPath "/post" postUUID ] []

                Edit postUUID ->
                    relative [ UUID.toPath "/post/edit" postUUID ] []

                Delete postUUID ->
                    relative [ UUID.toPath "/post/delete" postUUID ] []

        About ->
            relative [ "/about" ] []

        Donate ->
            relative [ "/donate" ] []

        Changelog ->
            relative [ "/changelog" ] []

        NotFound ->
            relative [ "/404" ] []
