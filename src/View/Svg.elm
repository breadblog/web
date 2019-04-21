module View.Svg exposing (Icon, attribute, checkCircle, checkSquare, chevronDown, chevronLeft, chevronRight, chevronUp, github, linkedin, menu, search, user, xCircle, xSquare)

import Svg.Styled as Svg exposing (..)
import Svg.Styled.Attributes as Attributes exposing (..)


type alias Icon msg =
    List (Attribute msg) -> Svg msg


attribute : List (Attribute msg) -> Svg msg
attribute toSvgAttributes =
    Svg.svg
        (List.append
            [ Attributes.fill "fff"
            ]
            toSvgAttributes
        )
        []


search : List (Attribute msg) -> Svg msg
search attr =
    svg
        (List.append
            [ width "24", height "24", viewBox "0 0 24 24", fill "none", stroke "currentColor", strokeWidth "2", strokeLinecap "round", strokeLinejoin "round", class "feather feather-search" ]
            attr
        )
        [ circle
            [ cx "11", cy "11", r "8" ]
            []
        , line
            [ x1 "21", y1 "21", x2 "16.65", y2 "16.65" ]
            []
        ]


user : List (Attribute msg) -> Svg msg
user attr =
    svg (List.append [ width "24", height "24", viewBox "0 0 24 24", fill "none", stroke "currentColor", strokeWidth "2", strokeLinecap "round", strokeLinejoin "round", class "feather feather-user" ] attr) [ Svg.path [ d "M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" ] [], circle [ cx "12", cy "7", r "4" ] [] ]


github : List (Attribute msg) -> Svg msg
github attr =
    svg (List.append [ width "24", height "24", viewBox "0 0 24 24", fill "none", stroke "currentColor", strokeWidth "2", strokeLinecap "round", strokeLinejoin "round", class "feather feather-github" ] attr) [ Svg.path [ d "M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22" ] [] ]


linkedin : List (Attribute msg) -> Svg msg
linkedin attr =
    svg (List.append [ width "24", height "24", viewBox "0 0 24 24", fill "none", stroke "currentColor", strokeWidth "2", strokeLinecap "round", strokeLinejoin "round", class "feather feather-linkedin" ] attr) [ Svg.path [ d "M16 8a6 6 0 0 1 6 6v7h-4v-7a2 2 0 0 0-2-2 2 2 0 0 0-2 2v7h-4v-7a6 6 0 0 1 6-6z" ] [], rect [ x "2", y "9", width "4", height "12" ] [], circle [ cx "4", cy "4", r "2" ] [] ]


chevronDown : List (Attribute msg) -> Svg msg
chevronDown attr =
    svg (List.append [ width "24", height "24", viewBox "0 0 24 24", fill "none", stroke "currentColor", strokeWidth "2", strokeLinecap "round", strokeLinejoin "round", class "feather feather-chevron-down" ] attr) [ polyline [ points "6 9 12 15 18 9" ] [] ]


chevronLeft : List (Attribute msg) -> Svg msg
chevronLeft attr =
    svg (List.append [ width "24", height "24", viewBox "0 0 24 24", fill "none", stroke "currentColor", strokeWidth "2", strokeLinecap "round", strokeLinejoin "round", class "feather feather-chevron-left" ] attr) [ polyline [ points "15 18 9 12 15 6" ] [] ]


chevronRight : List (Attribute msg) -> Svg msg
chevronRight attr =
    svg (List.append [ width "24", height "24", viewBox "0 0 24 24", fill "none", stroke "currentColor", strokeWidth "2", strokeLinecap "round", strokeLinejoin "round", class "feather feather-chevron-right" ] attr) [ polyline [ points "9 18 15 12 9 6" ] [] ]


chevronUp : List (Attribute msg) -> Svg msg
chevronUp attr =
    svg (List.append [ width "24", height "24", viewBox "0 0 24 24", fill "none", stroke "currentColor", strokeWidth "2", strokeLinecap "round", strokeLinejoin "round", class "feather feather-chevron-up" ] attr) [ polyline [ points "18 15 12 9 6 15" ] [] ]


checkSquare : List (Attribute msg) -> Svg msg
checkSquare attr =
    svg (List.append [ width "24", height "24", viewBox "0 0 24 24", fill "none", stroke "currentColor", strokeWidth "2", strokeLinecap "round", strokeLinejoin "round", class "feather feather-check-square" ] attr) [ polyline [ points "9 11 12 14 22 4" ] [], Svg.path [ d "M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11" ] [] ]


xSquare : List (Attribute msg) -> Svg msg
xSquare attr =
    svg (List.append [ width "24", height "24", viewBox "0 0 24 24", fill "none", stroke "currentColor", strokeWidth "2", strokeLinecap "round", strokeLinejoin "round", class "feather feather-x-square" ] attr) [ rect [ x "3", y "3", width "18", height "18", rx "2", ry "2" ] [], line [ x1 "9", y1 "9", x2 "15", y2 "15" ] [], line [ x1 "15", y1 "9", x2 "9", y2 "15" ] [] ]


checkCircle : List (Attribute msg) -> Svg msg
checkCircle attr =
    svg (List.append [ width "24", height "24", viewBox "0 0 24 24", fill "none", stroke "currentColor", strokeWidth "2", strokeLinecap "round", strokeLinejoin "round", class "feather feather-check-circle" ] attr) [ Svg.path [ d "M22 11.08V12a10 10 0 1 1-5.93-9.14" ] [], polyline [ points "22 4 12 14.01 9 11.01" ] [] ]


xCircle : List (Attribute msg) -> Svg msg
xCircle attr =
    svg (List.append [ width "24", height "24", viewBox "0 0 24 24", fill "none", stroke "currentColor", strokeWidth "2", strokeLinecap "round", strokeLinejoin "round", class "feather feather-x-circle" ] attr) [ circle [ cx "12", cy "12", r "10" ] [], line [ x1 "15", y1 "9", x2 "9", y2 "15" ] [], line [ x1 "9", y1 "9", x2 "15", y2 "15" ] [] ]


menu : List (Attribute msg) -> Svg msg
menu attr =
    svg (List.append [ width "24", height "24", viewBox "0 0 24 24", fill "none", stroke "currentColor", strokeWidth "2", strokeLinecap "round", strokeLinejoin "round", class "feather feather-menu" ] attr) [ line [ x1 "3", y1 "12", x2 "21", y2 "12" ] [], line [ x1 "3", y1 "6", x2 "21", y2 "6" ] [], line [ x1 "3", y1 "18", x2 "21", y2 "18" ] [] ]
