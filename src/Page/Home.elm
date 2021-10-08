module Page.Home exposing (..)

import Components.Logo exposing (logo)
import Components.News as N
import Html exposing (..)
import Html.Attributes exposing (..)
import Template


urlMatrix : String
urlMatrix =
    "https://matrix.to/#/!OStoLwCDcJOPJCxkHA:matrix.org?via=matrix.org"


urlDiscord : String
urlDiscord =
    "https://discord.gg/cXbe3TVYcd"


newsLists : List N.News
newsLists =
    [ N.News "Contribute to Open Source with HacktoberFest" "Lintang Aji Yoga Pratama" "Minggu, 10 Oktober 2021 | 09:00 Pagi" "https://s.id/HiZKH" "hf2021.png"
    ]


view : Template.Meta msg
view =
    { title = "Home"
    , header = []
    , attrs = []
    , children =
        [ div [ class "home" ]
            [ div [ class "logo" ] [ logo ]
            , div [ class "info" ]
                [ h2 [] [ text "Perkumpulan mahasiswa pegiat pemrograman." ]
                , a [ href urlDiscord, class "btnJoin" ] [ text "Gabung Sekarang!" ]
                , p [] [ text "atau, baca ", a [ href "/about" ] [ text "tentang kami." ] ]
                ]
            ]
        , div []
            [ h2 [ class "text-center" ] [ text "Event Kami" ]
            , div [ class "news" ] (List.map N.viewNews newsLists)
            ]
        ]
    }
