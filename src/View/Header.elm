module View.Header exposing (Model, Msg(..), init, update, view)

import Css exposing (..)
import Css.Media as Media exposing (only, screen, withMedia)
import Css.Transitions as Transitions exposing (transition)
import Data.Author as Author exposing (Author)
import Data.Cache as Cache exposing (Msg(..))
import Data.Route as Route exposing (Route(..))
import Data.Search as Search exposing (Result, Source)
import Data.Tag as Tag exposing (Tag)
import Data.Theme as Theme exposing (Theme(..))
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Html.Styled.Events exposing (onClick, onInput)
import Message exposing (Compound(..), Msg(..))
import Style.Color as Color
import Style.Dimension as Dimension
import Style.Font as Font
import Style.Screen as Screen exposing (Screen(..))
import Style.Shadow as Shadow
import Svg.Styled.Attributes
import View.Svg as Svg



{-
   Application Header
   ==================

   Although this is on many of the pages in the application, this is not
   a hard and fast rule. There are several pages where we might not want
   to show the header (such as the error pages) where we want more fine
   tuned control over how the user navigates on a page

   Layouts
   =======

   The header supports two different layouts, depending on screen it is
   being used on

   Full
   ----

   The full experience makes use of the extra space and dexterity using
   a series of dropdowns & links for navigation and for more accessible
   control of displayed content

   ---------------------------------------
   | Logo Dropdowns Search Links Profile |
   ---------------------------------------

   Mobile
   ------

   The mobile experience has to accommodate the fat fingered among us,
   so everything needs to be either clickable or toggleable. Hence the
   addition of a hamburger menu which opens into a drawer on the left,
   allowing navigation to the different pages here. Control over content
   is not accessible from the header in this layout

   ---------------------------------------
   | Hamburger                    Search |
   ---------------------------------------
   |                   |
   |   Home            |
   |   Profile         |
   |   Authors         |
   |   About           |
   |   Donate          |
   |                   |

-}
-- Model --


type alias Model =
    { searchBarFocused : Bool
    , searchTerm : String
    , drawerOpenOnMobile : Bool
    , searchOpenOnMobile : Bool
    , route : Route
    }


init : Route -> Model
init route =
    { searchBarFocused = False
    , searchTerm = ""
    , drawerOpenOnMobile = False
    , searchOpenOnMobile = False
    , route = route
    }



-- Message --


type Msg
    = FocusSearch Bool
    | SetSearchTerm String
    | ToggleDrawer
    | ToggleSearch



-- Update --


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FocusSearch value ->
            ( focusSearch value model, Cmd.none )

        SetSearchTerm value ->
            ( { model | searchTerm = value }, Cmd.none )

        ToggleDrawer ->
            ( { model | drawerOpenOnMobile = not model.drawerOpenOnMobile }, Cmd.none )

        ToggleSearch ->
            let
                focusedModel =
                    focusSearch True model
            in
            ( { focusedModel | searchOpenOnMobile = not model.searchOpenOnMobile }, Cmd.none )


focusSearch : Bool -> Model -> Model
focusSearch value model =
    let
        searchTerm =
            if value == False then
                ""

            else
                model.searchTerm

        searchOpenOnMobile =
            value
    in
    { model | searchBarFocused = value, searchTerm = searchTerm, searchOpenOnMobile = searchOpenOnMobile }



-- View --


view : (Compound Msg -> msg) -> Theme -> List Author -> List Tag -> Model -> List (Html msg)
view transform theme authors tags model =
    List.map
        (Html.Styled.map transform)
        (viewHeader theme authors tags model)


viewHeader : Theme -> List Author -> List Tag -> Model -> List (Html (Compound Msg))
viewHeader theme authors tags model =
    let
        sources =
            [ Tag.toSource (Global NoOp) tags
            ]
    in
    [ header
        [ css
            [ position relative
            , displayFlex
            , flexDirection row
            , alignItems center
            , justifyContent spaceBetween
            , Css.height (px Dimension.headerHeight)
            , Css.width (pct 100)
            , backgroundColor (Color.primary theme)
            , Shadow.dp6
            , zIndex <| int 15
            ]
        ]
        -- MOBILE
        [ drawerMenu <| not model.searchOpenOnMobile

        -- DESKTOP
        , fixedSpacer Screen.desktop <| px 25
        , logo Screen.desktop theme
        , spacer Screen.desktop
        , dropdown Screen.desktop theme "tags" <| tagsContent theme tags
        , dropdown Screen.desktop theme "author" <| authorsContent theme authors

        -- BOTH
        , spacer Screen.desktop
        , searchBar theme model.searchOpenOnMobile model.searchTerm
        , spacer Screen.desktop

        -- MOBILE
        , title theme model.route (not model.searchOpenOnMobile)

        -- DESKTOP
        , dropdown Screen.desktop theme "theme" <| themeContent theme
        , navLink Screen.desktop theme "about" About
        , navLink Screen.desktop theme "donate" Donate
        , spacer Screen.desktop
        , profile Screen.desktop theme
        , fixedSpacer Screen.desktop (px 25)

        -- MOBILE
        , searchOpen <| not model.searchOpenOnMobile
        ]

    -- search bar overlay: header > overlay > content
    , searchOverlay theme model.searchBarFocused 10

    -- drawer overlay: drawer > overlay > header > content
    , drawerOverlay theme model.drawerOpenOnMobile 20

    -- drawer: drawer > header
    , drawer theme model.drawerOpenOnMobile 25
    ]



-- BOTH --
-- Search


searchBar : Theme -> Bool -> String -> Html (Compound Msg)
searchBar theme openOnMobile searchTerm =
    div
        [ class "search"
        , css
            [ displayFlex
            , flexDirection row
            , position relative
            , Css.height (px 36)
            , zIndex <| int 15

            -- Mobile styling
            , Screen.style
                Screen.mobile
                [ Css.batch <|
                    if openOnMobile then
                        []

                    else
                        [ display none ]
                , flexGrow <| num 1
                , margin2 (px 0) (px 10)
                ]

            -- Desktop styling
            , Screen.style
                Screen.desktop
                [ Css.width <| px 260
                ]
            ]
        , onClick <| Mod (FocusSearch True)
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
            , onInput (\s -> Mod <| SetSearchTerm s)
            , value searchTerm
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



-- MOBILE --


drawerMenu : Bool -> Html (Compound Msg)
drawerMenu showOnMobile =
    let
        iconSize =
            18

        topBtmPadding =
            (Dimension.headerHeight - iconSize) / 2
    in
    div
        [ class "drawer-menu"
        , css
            [ Screen.showOn Screen.mobile
            , padding2 (px topBtmPadding) mobileIconPadding
            , Css.batch <|
                if showOnMobile then
                    []

                else
                    [ display none ]
            ]
        , onClick <| Mod <| ToggleDrawer
        ]
        [ Svg.menu
            [ Svg.Styled.Attributes.css
                [ Css.width <| px iconSize
                , Css.height <| px iconSize
                ]
            ]
        ]


searchOpen : Bool -> Html (Compound Msg)
searchOpen showOnMobile =
    let
        iconSize =
            18

        topBtmPadding =
            (Dimension.headerHeight - iconSize) / 2
    in
    div
        [ class "search-toggle"
        , css
            [ Screen.showOn Screen.mobile
            , padding2 (px topBtmPadding) mobileIconPadding
            , Css.batch <|
                if showOnMobile then
                    []

                else
                    [ display none ]
            ]
        , onClick <| Mod <| ToggleSearch
        ]
        [ Svg.search
            [ Svg.Styled.Attributes.css
                [ Css.width <| px iconSize
                , Css.height <| px iconSize
                ]
            ]
        ]


title : Theme -> Route -> Bool -> Html msg
title theme route show =
    let
        name =
            case route of
                Home ->
                    "Bits n' Bites"

                _ ->
                    Route.toName route
    in
    h1
        [ css
            [ fontFamilies Font.indieFlower
            , fontWeight normal
            , margin (px 0)
            , textDecoration none
            , fontSize <| rem 1.8
            , Screen.showOn Screen.mobile
            , Css.batch <|
                if show then
                    []

                else
                    [ display none ]
            ]
        ]
        [ text name ]


mobileIconPadding : Px
mobileIconPadding =
    px 18



-- Logo


logo : List Screen -> Theme -> Html msg
logo shownScreens theme =
    h1
        [ css [ Screen.showOn shownScreens ]
        ]
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



-- Tags


tagsContent : Theme -> List Tag -> List (Html (Compound Msg))
tagsContent theme =
    List.map
        (\t -> checkboxDropdownItem (Tag.name t) theme (Tag.watched t) (Global <| CacheMsg <| ToggleTag t))



-- Authors


authorsContent : Theme -> List Author -> List (Html (Compound Msg))
authorsContent theme =
    List.map
        (\a -> checkboxDropdownItem (Author.username a) theme (Author.watched a) (Global <| CacheMsg <| ToggleAuthor a))



-- Theme --


themeContent : Theme -> List (Html (Compound Msg))
themeContent theme =
    List.map
        (\t -> dropdownItem theme (Theme.toString t) (t == theme) (Global <| CacheMsg <| SetTheme t))
        Theme.all



-- Profile


profile : List Screen -> Theme -> Html msg
profile shownScreens theme =
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
            , Screen.showOn shownScreens
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



-- Drawer


drawer : Theme -> Bool -> Int -> Html msg
drawer theme show zInd =
    div
        [ class "drawer"
        , css
            [ position absolute
            , left <| px 0
            , top <| px 0
            , bottom <| px 0
            , Css.width <| pct 80
            , zIndex <| int zInd
            , backgroundColor <| Color.drawer theme
            , Css.batch <|
                if show then
                    []

                else
                    [ display none ]
            , Screen.showOn Screen.mobile
            ]
        ]
        []



-- Overlay


overlay : Theme -> List Screen -> Bool -> Int -> Compound Msg -> Html (Compound Msg)
overlay theme screens show zInd msg =
    div
        [ class "content-overlay"
        , css
            [ position absolute
            , top <| px Dimension.headerHeight
            , bottom <| px 0
            , Css.width <| pct 100
            , zIndex <| int zInd
            , backgroundColor <| Color.overlay theme
            , if show then
                display block

              else
                display none
            , Screen.showOn screens
            ]
        , onClick msg
        ]
        []


searchOverlay : Theme -> Bool -> Int -> Html (Compound Msg)
searchOverlay theme show zInd =
    overlay theme Screen.all show zInd (Mod <| FocusSearch False)


drawerOverlay : Theme -> Bool -> Int -> Html (Compound Msg)
drawerOverlay theme show zInd =
    overlay theme Screen.mobile show zInd (Mod <| ToggleDrawer)



-- Util


dropdown : List Screen -> Theme -> String -> List (Html msg) -> Html msg
dropdown showScreens theme name content =
    div
        [ class "dropdown"
        , css
            [ position relative
            , displayFlex
            , Css.height (pct 100)
            , alignItems center
            , spacing Right
            , padding2 (px 0) (px 10)
            , Screen.showOn showScreens
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
                , overflowY auto
                , overflowX Css.hidden
                ]
            ]
            content
        ]


dropdownItem : Theme -> String -> Bool -> msg -> Html msg
dropdownItem theme name selected msg =
    let
        underline =
            if selected then
                div
                    [ css
                        [ Css.height <| px 2
                        , backgroundColor <| Color.secondaryFont theme
                        , marginTop <| px 1
                        , displayFlex
                        , flex2 (num 0) (num 0)
                        ]
                    ]
                    []

            else
                text ""
    in
    div
        [ class "dropdown-item"
        , css
            [ paddingLeft <| px 20
            , Css.height <| px 50
            , displayFlex
            , alignItems center
            , flexGrow <| num 0
            , minWidth <| px 160
            , hover
                [ backgroundColor <| Color.dropdownActive theme ]
            , transition
                [ Transitions.backgroundColor 100 ]
            ]
        , onClick msg
        ]
        [ div
            [ css
                [ displayFlex
                , flexDirection column
                ]
            ]
            [ text name
            , underline
            ]
        ]


checkboxDropdownItem : String -> Theme -> Bool -> msg -> Html msg
checkboxDropdownItem name theme value msg =
    div
        [ class "dropdown-item"
        , css
            [ paddingLeft <| px 10
            , Css.height <| px 50
            , displayFlex
            , flex2 (num 0) (num 0)
            , alignItems center
            , justifyContent spaceBetween
            , transition
                [ Transitions.backgroundColor 100 ]
            , hover
                [ backgroundColor <| Color.dropdownActive theme
                ]
            ]
        , onClick msg
        ]
        [ span
            [ css
                [ marginRight <| px 30
                ]
            ]
            [ text name ]
        , checkbox value theme
        ]


checkbox : Bool -> Theme -> Html msg
checkbox value theme =
    let
        style =
            batch
                [ Css.height <| px 25
                , Css.width <| px 25
                , marginRight <| px 10
                ]
    in
    case value of
        True ->
            Svg.checkCircle
                [ Svg.Styled.Attributes.css
                    [ style
                    , color <| Color.secondaryFont theme
                    ]
                ]

        False ->
            Svg.xCircle
                [ Svg.Styled.Attributes.css
                    [ style
                    , color <| Color.danger theme
                    ]
                ]


linkTransitionTime : Float
linkTransitionTime =
    100


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
        [ Screen.style
            [ Phone ]
            [ marginStyle (px 10) ]
        , Screen.style
            [ Tablet ]
            [ marginStyle (px 15) ]
        , Screen.style
            [ SmallDesktop ]
            [ marginStyle (px 20) ]
        , Screen.style
            [ MediumDesktop ]
            [ marginStyle (px 25) ]
        , Screen.style
            [ LargeDesktop, HighResDesktop ]
            [ marginStyle (px 40) ]
        ]


spacer : List Screen -> Html msg
spacer shownScreens =
    div
        [ css
            [ flexGrow <| num 1
            , Screen.showOn shownScreens
            ]
        , class "spacer between"
        ]
        []


fixedSpacer : List Screen -> LengthOrAuto compatible -> Html msg
fixedSpacer shownScreens width_ =
    div
        [ css
            [ Css.width <| width_
            , Screen.showOn
                shownScreens
            ]
        , class "spacer fixed"
        ]
        []


navLink : List Screen -> Theme -> String -> Route -> Html msg
navLink shownScreens theme name route =
    div
        [ class "nav-link"
        , css
            [ spacing Right
            , Screen.showOn shownScreens
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
