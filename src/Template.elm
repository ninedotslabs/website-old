module Template exposing
    ( Meta
    , Segment
    , view
    )

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Lazy exposing (..)


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
    ul [ class "nav" ]
        [ viewLink { name = "Home", url = "/" }
        , viewLink { name = "Anggota", url = "/members" }
        , viewLink { name = "Repositori", url = "/repos" }
        ]


viewLink : Path -> Html msg
viewLink path =
    li []
        [ a [ href path.url ] [ text path.name ] ]


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
        [ p [] [ text "© 2020-Future Nine Dots Labs" ]
        ]
