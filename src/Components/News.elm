module Components.News exposing (News, viewNews)

import Html exposing (..)
import Html.Attributes exposing (alt, class, height, href, src, width)
import Json.Decode as JD exposing (Decoder, field, string)



-- TYPES


type alias News =
    { title : String
    , speaker : String
    , time : String
    , url : String
    , image : String
    }



-- DECODER


newsDecoder : Decoder News
newsDecoder =
    JD.map5 News
        (field "title" string)
        (field "speaker" string)
        (field "time" string)
        (field "url" string)
        (field "image" string)


newsListDecoder : Decoder (List News)
newsListDecoder =
    JD.list newsDecoder



-- PATH


pathNewsImgUrl =
    "/data/events/images/"



-- VIEWS


viewNews : News -> Html msg
viewNews news =
    div [ class "news-item" ]
        [ img [ src (pathNewsImgUrl ++ news.image), alt news.title, width 300, height 300 ] []
        , a [ href news.url ] [ text news.title ]
        ]
