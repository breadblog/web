module View.Header exposing (view)


import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Css exposing (..)
import Message exposing (Msg)
import Model exposing (Model)
import Style.Theme as Theme


view : Model -> Html Msg
view model =
    header
        [ css
            [ displayFlex
            , flexDirection row
            , justifyContent spaceBetween
            , alignItems center
            , Css.height (px 50)
            , Css.width (pct 100)
            , backgroundColor (Theme.primary model.cache)
            ]
        ]
        [ logo
        , searchBar model
        , menu model
        ]


logo : Html Msg
logo =
    div [] []


searchBar : Model -> Html Msg
searchBar model =
    div
        [ class "search"
        , css
            [ displayFlex
            , flexDirection row
            , position relative
            , Css.height (px 35)
            ]
        ]
        [ input
            [ class "search"
            , css
                [ flexGrow (num 1)
                , borderStyle solid
                , borderWidth (px 0)
                ]
            ]
            []
        , img
            [ src "/icons/search.svg"
            , css
                [ position absolute
                , right (px 0)
                , Css.height (px 24)
                , Css.width (px 24)
                , alignSelf center
                , marginRight (px 5)
                ]
            ]
            []
        ]


menu : Model -> Html Msg
menu model =
    div [] []
