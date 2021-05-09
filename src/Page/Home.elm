module Page.Home exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Template exposing (logo)


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
                , a [ href "https://discord.gg/3xmG5fX", {- target "_blank", rel "noopener noreferrer", -} class "btnJoin" ] [ text "Gabung Sekarang!" ]
                , p [] [ text "atau, baca ", a [ href "/about" ] [ text "tentang kami." ] ]
                ]
            ]
        ]
    }
