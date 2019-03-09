module Data.Slug exposing (Slug, toString, urlParser)


import Url.Parser exposing (Parser)


type Slug =
    Slug String


-- Util


urlParser : Parser (Slug -> a) a
urlParser =
    Url.Parser.custom "SLUG" (\str -> Just (Slug str))


toString : Slug -> String
toString (Slug slug) =
    slug
