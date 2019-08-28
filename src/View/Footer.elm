module View.Footer exposing (view)

import Css exposing (..)
import Css.Transitions as Transitions exposing (transition)
import Data.General as General exposing (General)
import Data.Route as Route exposing (Route(..))
import Data.Theme exposing (Theme)
import Data.Version exposing (Version)
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Style.Color as Color
import Style.Dimension as Dimension
import Svg.Styled.Attributes
import View.Svg as Svg exposing (Icon)


type alias Profile =
    { image : String
    , url : String
    , name : String
    }



-- Model --


type FooterPage
    = None
    | Github
    | LinkedIn



-- View --


view : Theme -> Version -> List (Html msg)
view theme version =
    viewFooter theme version


viewFooter : Theme -> Version -> List (Html msg)
viewFooter theme version =
    [ footer
        [ css
            [ displayFlex
            , flexDirection row
            , alignItems center
            , justifyContent spaceBetween
            , flex3 (int 0) (int 0) (px Dimension.headerHeight)
            , Css.width (pct 100)
            , backgroundColor (Color.primary theme)
            ]
        ]
        [ footerLeft theme version
        , footerRight theme
        ]
    ]


footerLeft : Theme -> Version -> Html msg
footerLeft theme version =
    div
        [ css
            []
        ]
        [ div
            -- [ href <| Route.toPath Changelog
            [ css
                [ textDecoration none
                , fontSize <| rem 1.1
                , letterSpacing <| px 1.5
                , margin (px 15)
                , color <| Color.secondaryFont theme

                -- , hover
                --     [ color <| Color.primaryFont theme
                --     ]
                ]
            ]
            [ text <| Data.Version.toString version
            ]
        ]


footerRight : Theme -> Html msg
footerRight theme =
    div
        [ css
            [ margin2 (px 0) (px 15)
            , displayFlex
            , flexDirection row
            ]
        ]
        [ options theme Svg.linkedin linkedinData
        , options theme Svg.github githubData
        ]


options : Theme -> Icon msg -> List Profile -> Html msg
options theme icon info =
    let
        iconSize =
            24
    in
    div
        [ class "footer-dropup"
        , css
            [ Css.height <| px <| Dimension.headerHeight - 20
            , Css.width <| px <| Dimension.headerHeight - 20
            , Css.margin <| px 10
            , displayFlex
            , justifyContent center
            , alignItems center
            , position relative
            , cursor pointer
            ]
        ]
        [ icon
            [ Svg.Styled.Attributes.css
                [ Css.width <| px iconSize
                , Css.height <| px iconSize
                , color <| Color.secondaryFont theme
                , transition
                    [ Transitions.color3 100 0 Transitions.ease ]
                , hover
                    [ color <| Color.primaryFont theme
                    ]
                ]
            ]
        , div
            [ class "footer-options"
            , css
                [ display none
                , position absolute
                , bottom <| px <| Dimension.headerHeight - 15
                , right <| px 0
                , backgroundColor <| Color.dropdown theme
                , after
                    [ position absolute
                    , bottom <| px -10
                    , borderWidth3 (px 10) (px 20) (px 0)
                    , borderColor2 (Color.dropdown theme) transparent
                    , borderStyle solid
                    , right <| px 0
                    , Css.property "content" "\"\""
                    , display block
                    ]
                ]
            ]
            (List.map
                (\d ->
                    a
                        [ class "footer-option"
                        , href d.url
                        , css
                            [ displayFlex
                            , flexDirection row
                            , alignItems center
                            , padding2 (px 9) (px 12)
                            , textDecoration none
                            , color <| Color.primaryFont theme
                            , transition
                                [ Transitions.color3 100 0 Transitions.ease ]
                            , hover
                                [ backgroundColor <| Color.dropdownActive theme ]
                            ]
                        ]
                        [ img
                            [ src d.image
                            , css
                                [ Css.height <| px 40
                                , Css.width <| px 40
                                , Css.property "clip-path" "circle(50%)"
                                , backgroundColor <| Color.dropdownContrast theme
                                ]
                            ]
                            []
                        , span
                            [ css
                                [ margin4 (px 0) (px 0) (px 0) (px 10)
                                , fontSize <| rem 1.2
                                ]
                            ]
                            [ text d.name ]
                        ]
                )
                info
            )
        ]


githubData : List Profile
githubData =
    [ { image = "https://avatars3.githubusercontent.com/u/47406828?s=200&v=4"
      , url = "https://github.com/BreadBlog"
      , name = "bits n' bites"
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
    [ { image = "/linkedin_brad.jpg"
      , url = "https://www.linkedin.com/in/brad-pfannmuller/"
      , name = "Brad"
      }
    , { image = "https://avatars2.githubusercontent.com/u/14334617?s=88&v=4"
      , url = "https://www.linkedin.com/in/beaesguerra/"
      , name = "Bea"
      }
    ]
