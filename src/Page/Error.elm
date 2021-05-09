module Page.Error exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)



-- NOT FOUND


notFound : List (Html msg)
notFound =
    [ div [ class "container" ]
        [ h2 [] [ text "404" ]
        , p [] [ text "Page not found!" ]
        ]
    ]



-- OFFLINE


offline : String -> List (Html msg)
offline file =
    [ div [ style "font-size" "3em" ]
        [ text "Cannot find "
        , code [] [ text file ]
        ]
    , p [] [ text "Are you offline or something?" ]
    ]
