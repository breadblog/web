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
import Style.Screen as Screen exposing (Screen)
import Style.Shadow as Shadow
import Svg.Styled.Attributes
import View.Svg as Svg



-- Model --


type alias Model =
    { searchBarFocused : Bool
    , searchTerm : String
    }


init : Model
init =
    { searchBarFocused = False
    , searchTerm = ""
    }



-- Message --


type Msg
    = FocusSearch Bool
    | SetSearchTerm String



-- Update --


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FocusSearch value ->
            let
                searchTerm =
                    if value == False then
                        ""

                    else
                        model.searchTerm
            in
            ( { model | searchBarFocused = value, searchTerm = searchTerm }, Cmd.none )

        SetSearchTerm value ->
            ( { model | searchTerm = value }, Cmd.none )



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
            , Css.height (px Dimension.headerHeight)
            , Css.width (pct 100)
            , backgroundColor (Color.primary theme)
            , Shadow.dp6
            , zIndex <| int 15
            ]
        ]
        -- Desktop
        [ fixedSpacer Screen.notPhone (px 25)
        , logo theme
        , spacer Screen.notPhone
        , dropdown Screen.notPhone theme "tags" <| tagsContent theme tags
        , dropdown Screen.notPhone theme "author" <| authorsContent theme authors
        , spacer Screen.notPhone
        , searchBar theme model.searchTerm
        , spacer Screen.notPhone
        , dropdown Screen.notPhone theme "theme" <| themeContent theme
        , navLink Screen.notPhone theme "about" About
        , navLink Screen.notPhone theme "donate" Donate
        , spacer Screen.notPhone
        , profile theme
        , fixedSpacer Screen.notPhone (px 25)

        -- Mobile
        ]
    , contentOverlay theme model.searchBarFocused
    ]



-- Overlays


contentOverlay : Theme -> Bool -> Html (Compound Msg)
contentOverlay theme show =
    div
        [ class "content-overlay"
        , css
            [ position absolute
            , top <| px Dimension.headerHeight
            , bottom <| px 0
            , Css.width <| pct 100
            , zIndex <| int 10
            , backgroundColor <| Color.overlay theme
            , if show then
                display block

              else
                display none
            ]
        , onClick <| Mod <| FocusSearch False
        ]
        []



-- Logo


logo : Theme -> Html msg
logo theme =
    h1
        [ css [ Screen.hideOn [ Screen.phone ] ]
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
        (\t -> checkboxDropdownItem (Tag.name t) theme (Tag.value t) (Global <| CacheMsg <| ToggleTag t))



-- Authors


authorsContent : Theme -> List Author -> List (Html (Compound Msg))
authorsContent theme =
    List.map
        (\a -> checkboxDropdownItem (Author.name a) theme (Author.value a) (Global <| CacheMsg <| ToggleAuthor a))



-- Search


searchBar : Theme -> String -> Html (Compound Msg)
searchBar theme searchTerm =
    div
        [ class "search"
        , css
            [ displayFlex
            , flexDirection row
            , position relative
            , Css.height (px 36)
            , Css.width (px 260)
            , zIndex <| int 15
            , List.map
                (\f -> f [ display none ])
                [ Screen.med, Screen.small, Screen.phone ]
                |> batch
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



-- Theme --


themeContent : Theme -> List (Html (Compound Msg))
themeContent theme =
    List.map
        (\t -> dropdownItem theme (Theme.toString t) (t == theme) (Global <| CacheMsg <| SetTheme t))
        Theme.all



-- Profile


profile : Theme -> Html msg
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
            , Screen.hideOn [ Screen.phone ]
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


drawer : Theme -> Html msg
drawer theme =
    text ""


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
                [ backgroundColor <| Color.highContrast theme ]
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
                [ backgroundColor <| Color.highContrast theme
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
        [ Screen.small [ marginStyle (px 10) ]
        , Screen.med [ marginStyle (px 15) ]
        , Screen.base [ marginStyle (px 20) ]
        , Screen.large [ marginStyle (px 25) ]
        , Screen.highRes [ marginStyle (px 40) ]
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


searchOverlay : Html msg
searchOverlay =
    text ""
