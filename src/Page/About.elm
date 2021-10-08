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
            ]
        ]
    }
