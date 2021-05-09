module Template exposing
    ( Meta
    , Segment
    , logo
    , view
    )

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Lazy exposing (..)
import Svg exposing (circle, g, svg)
import Svg.Attributes exposing (cx, cy, fill, r, viewBox)


type alias Meta msg =
    { title : String
    , header : List Segment
    , attrs : List (Attribute msg)
    , children : List (Html msg)
    }


type Segment
    = Text String
    | Link String String


type alias Path =
    { name : String
    , url : String
    }



-- VIEW


view : (a -> msg) -> Meta a -> Browser.Document msg
view toMsg meta =
    { title =
        meta.title
    , body =
        [ viewHeader meta.header
        , Html.map toMsg <|
            main_ (class "main" :: meta.attrs) meta.children
        , viewFooter
        ]
    }



-- VIEW HEADER


viewHeader : List Segment -> Html msg
viewHeader segments =
    header
        [ class "header" ]
        [ nav []
            [ viewNavigation
            , case segments of
                [] ->
                    text ""

                _ ->
                    h1 [] (List.intersperse slash (List.map viewSegment segments))
            ]
        ]


viewNavigation : Html msg
viewNavigation =
    ul
        [ class "nav"
        ]
        [ viewLink { name = "Home", url = "/" }
        , viewLink { name = "Anggota", url = "/members" }
        , viewLink { name = "Repositori", url = "/repos" }
        ]


viewLink : Path -> Html msg
viewLink path =
    li []
        [ a
            [ href path.url
            , style "text-decoration" "none"
            ]
            [ text path.name ]
        ]


slash : Html msg
slash =
    span [ class "spacey-char" ] [ text "/" ]


viewSegment : Segment -> Html msg
viewSegment segment =
    case segment of
        Text string ->
            text string

        Link address string ->
            a [ href address ] [ text string ]



-- VIEW FOOTER


viewFooter : Html msg
viewFooter =
    footer
        [ class "footer" ]
        [ p [] [ text "© 2020-2021 Nine Dots Labs" ]
        ]


logo : Html.Html msg
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
