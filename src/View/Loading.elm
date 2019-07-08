module View.Loading exposing (toHtml)

{-
   Thanks to Sam Herbert for providing the base for this
   svg, which is a tweaked version of his "puff" svg
   found on github.com/SamHerbert/SVG-Loaders
-}

import Html.Styled exposing (Html)
import Svg.Styled as Svg exposing (..)
import Svg.Styled.Attributes as Attr exposing (..)


multiplySize : Int -> Float -> (String -> attr) -> attr
multiplySize baseSize multiplier transform =
    baseSize
        |> toFloat
        |> (*) multiplier
        |> String.fromFloat
        |> transform


multiplyTime : Float -> Int -> (String -> attr) -> attr
multiplyTime baseTime multiplier transform =
    multiplier
        |> toFloat
        |> (*) baseTime
        |> String.fromFloat
        |> (\s ->
                s
                    ++ "s"
                    |> transform
           )


toHtml : { timing : Int, size : Float } -> Html msg
toHtml { timing, size } =
    svg
        [ multiplySize 44 size width
        , multiplySize 44 size height
        , size
            |> (*) 44
            |> String.fromFloat
            |> List.repeat 2
            |> List.append [ "0", "0" ]
            |> String.join " "
            |> viewBox
        , stroke "#fff"
        ]
        [ g
            [ fill "none"
            , fillRule "evenodd"

            -- strokeWidth
            , size
                |> (*) 0.8
                |> (+) 1.2
                |> String.fromFloat
                |> strokeWidth
            ]
            [ circle
                [ multiplySize 22 size cx
                , multiplySize 22 size cy
                , multiplySize 1 size r
                ]
                [ animate
                    [ attributeName "r"
                    , begin "0s"
                    , multiplyTime 1 timing dur
                    , size
                        |> (*) 20
                        |> String.fromFloat
                        |> (\i ->
                                "1; "
                                    ++ i
                                    |> values
                           )
                    , calcMode "spline"
                    , keyTimes "0; 1"
                    , keySplines "0.165, 0.84, 0.44, 1"
                    , repeatCount "indefinite"
                    ]
                    []
                , animate
                    [ attributeName "stroke-opacity"
                    , begin "0s"
                    , multiplyTime 1 timing dur
                    , values "1; 0"
                    , calcMode "spline"
                    , keyTimes "0; 1"
                    , keySplines "0.3 0.61 0.355 1"
                    , repeatCount "indefinite"
                    ]
                    []
                ]
            , circle
                [ multiplySize 22 size cx
                , multiplySize 22 size cy
                , multiplySize 2 size r
                ]
                [ animate
                    [ attributeName "r"
                    , multiplyTime -0.5 timing begin
                    , multiplyTime 1 timing dur
                    , size
                        |> (*) 20
                        |> String.fromFloat
                        |> (\i ->
                                "1; "
                                    ++ i
                                    |> values
                           )
                    , calcMode "spline"
                    , keyTimes "0; 1"
                    , keySplines "0.165, 0.84, 0.44, 1"
                    , repeatCount "indefinite"
                    ]
                    []
                , animate
                    [ attributeName "stroke-opacity"
                    , multiplyTime -0.5 timing begin
                    , multiplyTime 1 timing dur
                    , values "1; 0"
                    , calcMode "spline"
                    , keyTimes "0; 1"
                    , keySplines "0.3 0.61 0.355 1"
                    , repeatCount "indefinite"
                    ]
                    []
                ]
            ]
        ]
