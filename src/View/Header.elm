module View.Header exposing (view)

import Css exposing (..)
import Css.Media as Media exposing (only, screen, withMedia)
import Css.Transitions as Transitions exposing (transition)
import Data.Cache as Cache exposing (Msg(..))
import Data.Route as Route exposing (Route(..))
import Data.Theme exposing (Theme(..))
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Html.Styled.Events exposing (onClick)
import Message exposing (Msg(..))
import Svg.Styled.Attributes
import View.Svg as Svg
import Style.Font as Font
import Style.Screen as Screen
import Style.Color as Color
import Style.Dimension as Dimension
import Style.Shadow as Shadow


type alias Msg = Message.Msg


view : Theme -> Html Msg
view theme =
    header
        [ css
            [ displayFlex
            , flexDirection row
            , alignItems center
            , Css.height (px Dimension.headerHeight) 
            , Css.width (pct 100)
            , backgroundColor (Color.primary theme)
            , Shadow.dp6
            ]
        ]
        [ endSpacer
        , logo theme
        , spacer
        , dropdown theme "tags"
        , dropdown theme "author"
        , spacer
        , searchBar theme
        , spacer
        , dropdown theme "theme"
        , navLink theme "about" About
        , navLink theme "donate" Donate
        , spacer
        , profile theme
        , endSpacer
        ]


-- Logo


logo : Theme -> Html Msg
logo theme =
    h1
        []
        [ a
            [ css
                [ fontFamilies Font.indieFlower
                , fontWeight normal
                , margin (px 0)
                , cursor pointer
                , textDecoration none
                , color <| Color.primaryFont theme
                ]
            , href <| Route.toPath Home
            ]
            [ text "Bits n' Bites"
            ]
        ]


-- Search Bar


searchBar : Theme -> Html Msg
searchBar theme =
    div
        [ class "search"
        , css
            [ displayFlex
            , flexDirection row
            , position relative
            , Css.height (px 36)
            , Css.width (px 260)
            , List.map
                (\f -> f [ display none ])
                [ Screen.med, Screen.small, Screen.phone ]
                |> batch
            ]
        ]
        [ input
            [ class "search"
            , css
                [ flexGrow (num 1)
                , borderWidth (px 0)
                , outline none
                , backgroundColor (Color.accent theme)
                , color (Color.secondaryFont theme)
                , paddingLeft (px 11)
                , fontSize (rem 1)
                , fontFamilies Font.montserrat
                ]
            ]
            []
        , Svg.search
            [ Svg.Styled.Attributes.css
                [ position absolute
                , right (px 0)
                , Css.height (px 18)
                , Css.width (px 18)
                , alignSelf center
                , marginRight (px 8)
                , Css.color (Color.secondaryFont theme)
                ]
            ]
        ]

-- Profile


profile : Theme -> Html Msg
profile theme =
    let
        iconSize =
            28

        chevronSize =
            20
    in
    div
        [ class "profile"
        , css
            [ Css.height (pct 100)
            , displayFlex
            , flexDirection row
            ]
        ]
        [ Svg.user
            [ Svg.Styled.Attributes.css
                [ Css.color (Color.secondaryFont theme)
                , position relative
                , top (px 3)
                , Css.width (px iconSize)
                , Css.height (px iconSize)
                , alignSelf center
                , right (px 0)
                , marginLeft (px 10)
                , bottom (px 10)
                ]
            ]
        , Svg.chevronDown
            [ Svg.Styled.Attributes.css
                [ Css.color (Color.secondaryFont theme)
                , Css.height (px chevronSize)
                , Css.width (px chevronSize)
                , alignSelf center
                , position relative
                , top (px 2)
                ]
            ]
        ]


-- Util


-- TODO: When a dropdown is clicked, it should retain its "hover" status
-- TODO: Consider moving "hover" status out of Style.Global since onClick and onMouseOver will share effect
dropdown : Theme -> String -> Html Msg
dropdown theme name =
    div
        [ class "dropdown"
        , css
            [ position relative
            , displayFlex
            , Css.height (pct 100)
            , alignItems center
            , spacing Right
            , padding2 (px 0) (px 5)
            , hover
                [ cursor pointer
                ]
            ]
        ]
        [ h2
            [ class "dropdown-el"
            , css
                [ fontWeight (int 300)
                , fontSize (rem 1.5)
                , color <| Color.secondaryFont theme
                , hover
                    [ color <| Color.primaryFont theme ]
                , transition
                    [ Transitions.color3 linkTransitionTime 0 linkTransitionStyle ]
                ]
            ]
            [ text name ]
        , Svg.chevronDown
            [ Svg.Styled.Attributes.class "dropdown-el"
            , Svg.Styled.Attributes.css
                [ Css.color (Color.secondaryFont theme)
                , position relative
                , top (px 3)
                , Css.width (px 20)
                , Css.height (px 20)
                , alignSelf center
                , right (px 0)
                , marginLeft (px 10)
                , transition
                    [ Transitions.color3 linkTransitionTime 0 linkTransitionStyle ]
                ]
            ]
        , div
            [ class "dropdown-contents"
            , css
                [ position absolute
                , top <| px Dimension.headerHeight
                , left <| px 0
                , backgroundColor <| Color.dropdown theme
                , minWidth <| pct 100
                , maxHeight <| px 0
                , overflow Css.hidden
                , displayFlex
                , flexDirection column
                , animationDuration <| ms 700
                , fontSize <| rem 1.1
                , Css.width <| px 200
                ]
            ]
            [ checkboxDropdownItem "Development" theme True NoOp
            , dropdownItem "second"
            , dropdownItem "third"
            , dropdownItem "fourth"
            ]
        ]


dropdownItem : String -> Html msg
dropdownItem name =
    div
        [ class "dropdown-item"
        , css
            [ paddingLeft <| px 10
            , Css.height <| px 40
            , displayFlex
            , alignItems center
            , flexGrow <| num 0
            ]
        ]
        [ text name
        ]


checkboxDropdownItem : String -> Theme -> Bool -> Msg -> Html Msg
checkboxDropdownItem name theme value msg =
    div
        [ class "dropdown-item"
        , css
            [ paddingLeft <| px 10
            , Css.height <| px 40
            , displayFlex
            , alignItems center
            , justifyContent spaceBetween
            ]
        ]
        [ text name
        , checkbox True theme
        ]


-- TODO: Make styling not suck
checkbox : Bool -> Theme -> Html msg
checkbox value theme =
    div
        [ css
            [ Css.height <| px 20
            , Css.width <| px 20
            , borderWidth <| px 2
            , borderStyle solid
            , borderColor <| Color.secondary theme
            , backgroundColor <| Color.primary theme
            , marginRight <| px 10
            ]
        ]
        []


linkTransitionTime : Float
linkTransitionTime =
    250


linkTransitionStyle =
    Transitions.ease


type Side
    = Right
    | Left


spacing : Side -> Style
spacing side =
    let
        marginStyle =
            case side of
                Left ->
                    marginLeft

                Right ->
                    marginRight
    in
    batch
        [ Screen.small [ marginStyle (px 10) ]
        , Screen.med [ marginStyle (px 15) ]
        , Screen.base [ marginStyle (px 20) ]
        , Screen.large [ marginStyle (px 25) ]
        , Screen.highRes [ marginStyle (px 40) ]
        ]


spacer : Html msg
spacer =
    div
        [ css
            [ flexGrow <| num 1
            , Screen.phone
                [ flexGrow <| num 0 ]
            ]
        , class "spacer between"
        ]
        []


endSpacer : Html msg
endSpacer =
    div
        [ css
            [ Css.width <| px 25
            , Screen.phone
                [ Css.width <| px 0 ]
            ]
        , class "spacer end"
        ]
        []


navLink : Theme -> String -> Route -> Html Msg
navLink theme name route =
    div
        [ class "nav-link"
        , css
            [ spacing Right
            ]
        ]
        [ a
            [ css
                [ textDecoration none
                , display block
                , color (Color.secondaryFont theme)
                , fontSize (rem 1.5)
                , fontWeight (int 300)
                , transition
                    [ Transitions.transform3 linkTransitionTime 0 linkTransitionStyle
                    , Transitions.color3 linkTransitionTime 0 linkTransitionStyle
                    ]
                , hover
                    [ color (Color.primaryFont theme)
                    , transform <| scale 1.02
                    ]
                ]
            , href (Route.toPath route)
            ]
            [ text name ]
        ]


searchResults : Theme -> Html Msg
searchResults theme =
    text ""


searchOverlay : Html Msg
searchOverlay =
    text ""
