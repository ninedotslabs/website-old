module Page.Repos exposing (Entries(..), Model, Msg(..), Repo, Repos, getRepos, init, renderRepo, repoDecoder, reposDecoder, update, view)

import Components.Logo exposing (spinner)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Iso8601
import Json.Decode as JD exposing (Decoder, field, int, nullable, string)
import Json.Decode.Pipeline as JDP
import Template exposing (..)
import Time exposing (millisToPosix, now, toYear, utc)
import Utils.Endpoint exposing (..)


type alias Model =
    { title : String
    , entries : Entries
    }


type Entries
    = Failure
    | Loading
    | Success Repos


type alias Repo =
    { name : String
    , description : Maybe String
    , html_url : String
    , homepage : Maybe String
    , created_at : String
    , updated_at : String
    , forks : Int
    , watchers : Int
    , topics : Topics
    }


type alias Topics =
    List String


type alias Repos =
    List Repo


type Msg
    = Reload
    | GotRepos (Result Http.Error Repos)



-- DECODER


repoDecoder : Decoder Repo
repoDecoder =
    JD.succeed Repo
        |> JDP.required "name" string
        |> JDP.required "description" (nullable string)
        |> JDP.required "html_url" string
        |> JDP.required "homepage" (nullable string)
        |> JDP.required "created_at" string
        |> JDP.required "updated_at" string
        |> JDP.required "forks" int
        |> JDP.required "watchers" int
        |> JDP.required "topics" (JD.list string)


reposDecoder : Decoder Repos
reposDecoder =
    JD.list repoDecoder


init : () -> ( Model, Cmd Msg )
init _ =
    ( { title = "Repos", entries = Loading }, getRepos apiGHOrgRepos )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Reload ->
            ( { model | entries = Loading }, getRepos apiGHOrgRepos )

        GotRepos result ->
            result
                |> Result.map (\repos -> ( { model | entries = Success repos }, Cmd.none ))
                |> Result.withDefault ( { model | entries = Failure }, Cmd.none )


styleRepos : List (Attribute msg)
styleRepos =
    [ style "margin" "3rem 0px 10px 0px"
    , style "border" "2px solid black"
    , style "color" "#fff"
    ]


styleRepoButton : List (Attribute msg)
styleRepoButton =
    [ style "margin" "10px 5px"
    , style "border" "2px solid #589bd5"
    , style "padding" "10px"
    , style "border-radius" "15px"
    , style "cursor" "pointer"
    ]



-- VIEW


view : Model -> Template.Meta Msg
view model =
    case model.entries of
        Failure ->
            { title = model.title
            , header = []
            , attrs = []
            , children =
                [ div [ style "text-align" "center" ]
                    [ p (style "background-color" "#000" :: styleRepos) [ text "Error loading repos." ]
                    , button
                        (onClick Reload :: styleRepoButton)
                        [ text "Try Again!" ]
                    ]
                ]
            }

        Loading ->
            { title = model.title
            , header = []
            , attrs = []
            , children =
                [ div [ style "text-align" "center" ]
                    [ p [ style "margin" "3rem 0px 10px 0px" ] [ spinner ] ]
                ]
            }

        Success repos ->
            { title = model.title
            , header = []
            , attrs = []
            , children =
                [ div
                    [ class "container" ]
                    [ h2 [] [ text "Repositori" ]
                    , div
                        [ class "repo" ]
                        (repos |> List.map renderRepo)
                    ]
                ]
            }


renderRepo : Repo -> Html Msg
renderRepo repo =
    let
        getYear s =
            s
                |> Iso8601.toTime
                |> Result.withDefault (millisToPosix 0)
                |> toYear utc
    in
    div
        [ style "margin" "5px"
        , style "text-align" "center"
        , style "border-radius" "15px"
        , style "overflow" "auto"
        , style "border" "2px solid black"
        , style "width" "300px"
        , style "min-height" "450px"
        ]
        [ div [ style "border-bottom" "2px solid black", class "pl-2 pr-2" ]
            [ a
                [ href repo.html_url
                , target "_blank"
                , rel "noopener noreferrer"
                , style "text-decoration" "none"
                ]
                [ h2 [] [ text repo.name ] ]
            , p []
                [ text
                    (Maybe.withDefault "no description." repo.description)
                ]
            ]
        , div [ class "pt-2 pb-2" ]
            [ p []
                [ span [ class "mr-2" ]
                    [ i [ class "fa fa-code-fork" ] [], viewFromInt repo.forks ((\a -> " " ++ a) >> text) ]
                , span []
                    [ i [ class "fa fa-eye" ] [], viewFromInt repo.watchers ((\a -> " " ++ a) >> text) ]
                ]
            , p []
                [ span [ class "mr-2" ]
                    [ i [ class "fa fa-history" ] []
                    , viewFromInt
                        (repo.created_at |> getYear)
                        ((\a -> " " ++ a) >> text)
                    ]
                , span []
                    [ i [ class "fa fa-refresh" ] []
                    , viewFromInt
                        (repo.updated_at |> getYear)
                        ((\a -> " " ++ a) >> text)
                    ]
                ]
            , case repo.homepage of
                Just hp ->
                    if hp /= "" then
                        a [ href hp, target "_blank", rel "noopener noreferrer" ] [ text "view homepage" ]

                    else
                        text ""

                Nothing ->
                    text ""
            ]
        , ul
            [ style "list-style-type" "none"
            , style "display" "flex"
            , style "flex-direction" "row"
            , style "flex-wrap" "wrap"
            , style "margin" "0px"
            , style "padding" "0px"
            , style "border-top" "2px solid black"
            , style "overflow" "auto"
            ]
            (List.reverse repo.topics |> List.map (\a -> li [ class "p-2" ] [ text a ]))
        ]


addS i a =
    a
        ++ (if i > 1 then
                "s"

            else
                ""
           )


viewFromInt : Int -> (String -> Html msg) -> Html msg
viewFromInt i f =
    i
        |> String.fromInt
        |> f


getRepos : String -> Cmd Msg
getRepos url =
    Http.get
        { url = url
        , expect = Http.expectJson GotRepos reposDecoder
        }
