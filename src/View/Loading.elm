module View.Loading exposing (toHtml)


{-
    Thanks to Sam Herbert for providing the base for this
    svg, which is a tweaked version of his "puff" svg
    found on github.com/SamHerbert/SVG-Loaders
-}


import Svg.Styled as Svg exposing (..)
import Svg.Styled.Attributes as Attr exposing (..)
import Html.Styled exposing (Html)


toHtml : Html msg
toHtml =
    svg
        [ width "44"
        , height "44"
        , viewBox "0 0 44 44"
        , stroke "#fff"
        ]
        [ g
            [ fill "none"
            , fillRule "evenodd"
            , strokeWidth "2"
            ]
            [ circle
                [ cx "22"
                , cy "22"
                , r "1"
                ]
                [ animate
                    [ attributeName "r"
                    , begin "0s"
                    , dur "3s"
                    , values "1; 20"
                    , calcMode "spline"
                    , keyTimes "0; 1"
                    , keySplines "0.165, 0.84, 0.44, 1"
                    , repeatCount "indefinite"
                    ]
                    []
                , animate
                    [ attributeName "stroke-opacity"
                    , begin "0s"
                    , dur "3s"
                    , values "1; 0"
                    , calcMode "spline"
                    , keyTimes "0; 1"
                    , keySplines "0.3 0.61 0.355 1"
                    , repeatCount "indefinite"
                    ]
                    []
                ]
            , circle
                [ cx "22"
                , cy "22"
                , r "2"
                ]
                [ animate
                    [ attributeName "r"
                    , begin "-1.5s"
                    , dur "3s"
                    , values "1; 20"
                    , calcMode "spline"
                    , keyTimes "0; 1"
                    , keySplines "0.165, 0.84, 0.44, 1"
                    , repeatCount "indefinite"
                    ]
                    []
                , animate
                    [ attributeName "stroke-opacity"
                    , begin "-1.5s"
                    , dur "3s"
                    , values "1; 0"
                    , calcMode "spline"
                    , keyTimes "0; 1"
                    , keySplines "0.3 0.61 0.355 1"
                    , repeatCount "indefinite"
                    ]
                    []
                -- TODO: add another circle
                -- TODO: make the animation larger
                ]
            ]
        ]


{- TODO: Complete
    Learning Corner
    ===============


    How do animations work?
    -----------------------


    What is calcMode?
    -----------------


    What are key splines?
    ---------------------


    What are animation values?
    --------------------------
-}
