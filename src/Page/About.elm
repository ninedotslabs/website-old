module Page.About exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Template


view : Template.Meta msg
view =
    { title = "About"
    , header = []
    , attrs = []
    , children =
        [ div [ class "container" ]
            [ h1 [] [ text "Tentang" ]
            , p [] [ text "Perkumpulan mahasiswa pegiat ", a [ href "/todos" ] [ text "pemrograman." ] ]
            , p [] [ text "Kami independen, tidak terikat dengan nama kampus atau organisasi intra/ekstra kampus manapun." ]
            , p [] [ text "Karena founder member dari kampus UIN Walisongo Semarang, kami sementara membuka bagi mahasiswa UIN Walisongo Semarang terutama Teknologi Informasi." ]
            , p [] [ text "Kami terbuka untuk sharing ilmu seputar teknologi informasi, pemrograman, maupun teknologi-teknologi terbaru lainnya." ]
            , p [] [ text "Member tidak mencerminkan member sebagai mahasiswa kampus X, jadi tidak ada hubungannya dengan politik, ekonomi, sosial, budaya, akademis, dan lainnya dari kampus X." ]
            ]
        ]
    }
