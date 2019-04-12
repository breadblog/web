module View.Footer exposing (view)

import Css exposing (..)
import Data.Theme exposing (Theme)
import Data.Version exposing (Version)
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Message exposing (Compound(..), Msg(..))
import Style.Color as Color
import Style.Dimension as Dimension
import Svg.Styled.Attributes as SvgAttr
import View.Svg as Svg exposing (Icon)


type alias Profile =
    { image : String
    , url : String
    , name : String
    }



-- View --


view : Theme -> Version -> Html (Compound msg)
view theme version =
    footer
        [ css
            [ displayFlex
            , flexDirection row
            , alignItems center
            , justifyContent spaceBetween
            , Css.height <| px Dimension.headerHeight
            , Css.width (pct 100)
            , backgroundColor (Color.primary theme)
            ]
        ]
        [ footerLeft theme version
        , footerRight theme
        ]


footerLeft : Theme -> Version -> Html (Compound msg)
footerLeft theme version =
    div
        [ css
            [ margin (px 15)
            , fontSize <| rem 1.1
            , letterSpacing <| px 1.5
            ]
        ]
        [ text <| Data.Version.toString version
        ]


footerRight : Theme -> Html (Compound msg)
footerRight theme =
    div
        [ css
            [ margin2 (px 0) (px 15)
            , displayFlex
            , flexDirection row
            ]
        ]
        [ options Svg.linkedin linkedinData
        , options Svg.github githubData
        ]



-- (List.map
--     (\x ->
--         a
--             [ href x.path
--             , Attr.target "_blank"
--             , css
--                 [ textDecoration none
--                 , color inherit
--                 ]
--             ]
--         [ x.icon
--             [ SvgAttr.css
--                 [ margin (px 5) ]
--             ]
--         ]
--     )
--     [ { icon = Svg.github
--       , path = "https://www.google.com"
--       }
--     , { icon = Svg.linkedin
--       , path = "https://www.google.com"
--       }
--     ]
-- )


options : Icon msg -> List Profile -> Html msg
options icon info =
    let
        iconSize =
            24
    in
    div
        [ class "footer-dropup"
        , css
            [ Css.height <| px Dimension.headerHeight
            , Css.width <| px Dimension.headerHeight
            , displayFlex
            , justifyContent center
            , alignItems center
            ]
        ]
        [ icon
            [ Svg.Styled.Attributes.css
                [ Css.width <| px iconSize
                , Css.height <| px iconSize
                , marginLeft <| px 15
                ]
            ]
        , div
            [ class "footer-options"
            , css
                [ opacity <| num 0
                , position absolute
                , top <| pct -100
                ]
            ]
            (List.map
                (\d ->
                    div
                        [ class "footer-option" ]
                        [ a
                            []
                            []
                        , text d.name
                        ]
                )
                info
            )
        ]


githubData : List Profile
githubData =
    [ { image = "https://avatars3.githubusercontent.com/u/47406828?s=200&v=4"
      , url = "https://github.com/BreadBlog"
      , name = "blog"
      }
    , { image = "https://avatars2.githubusercontent.com/u/14935550?s=88&v=4"
      , url = "https://github.com/Parasrah"
      , name = "parasrah"
      }
    , { image = "https://avatars2.githubusercontent.com/u/14334617?s=88&v=4"
      , url = "https://github.com/beaesguerra"
      , name = "beaesguerra"
      }
    ]


linkedinData : List Profile
linkedinData =
    [ { image = "https://media.licdn.com/dms/image/C4E03AQH4-cXdOSa0XA/profile-displayphoto-shrink_200_200/0?e=1560384000&v=beta&t=Jd8g1c3ar0brwM23WvGHhX6Mu7oQWRwOHylYxPJWurk"
      , url = "https://www.linkedin.com/in/brad-pfannmuller/"
      , name = "Brad"
      }
    , { image = "https://media.licdn.com/dms/image/C5603AQGrSRbS5xe4mw/profile-displayphoto-shrink_800_800/0?e=1560384000&v=beta&t=d_ua12Cz-eZCIcooUFUzwb5nBxEq6SO0yPlt6EkSTgE"
      , url = "https://www.linkedin.com/in/beaesguerra/"
      , name = "Bea"
      }
    ]
