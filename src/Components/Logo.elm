module Components.Logo exposing (logo, spinner)

import Html exposing (..)
import Html.Attributes exposing (..)
import Svg exposing (circle, g, svg)
import Svg.Attributes exposing (cx, cy, fill, r, viewBox)


spinner : Html msg
spinner =
    div [ class "spinner" ] [ logo ]


logo : Html msg
logo =
    svg [ width 300, height 350, viewBox "0 -50 210 250" ]
        [ g [ fill "#589bd5" ]
            [ circle [ cx "104.9", cy "120.97", r "7.9472" ]
                []
            , circle [ cx "104.9", cy "57.986", r "7.9472" ]
                []
            , circle [ cx "136.39", cy "89.479", r "7.9472" ]
                []
            , circle [ cx "41.916", cy "89.479", r "7.9472" ]
                []
            , circle [ cx "167.89", cy "89.479", r "7.9472" ]
                []
            , circle [ cx "73.409", cy "89.479", r "7.9472" ]
                []
            , circle [ cx "104.9", cy "26.494", r "7.9472" ]
                []
            , circle [ cx "136.39", cy "57.986", r "7.9472" ]
                []
            , circle [ cx "73.409", cy "57.986", r "7.9472" ]
                []
            ]
        ]
