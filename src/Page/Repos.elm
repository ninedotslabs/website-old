module Page.Repos exposing (Entries(..), Model, Msg(..), Repo, Repos, getRepos, init, renderRepo, repoDecoder, reposDecoder, update, view)

import Components.Logo exposing (spinner)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Iso8601
import Json.Decode as JD exposing (Decoder, field, int, string)
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
    }


type Topics
    = List String


type alias Repos =
    List Repo


type Msg
    = Reload
    | GotRepos (Result Http.Error Repos)



-- DECODER


repoDecoder : Decoder Repo
repoDecoder =
    JD.map8 Repo
        (field "name" string)
        (JD.maybe (field "description" string))
        (field "html_url" string)
        (JD.maybe (field "homepage" string))
        (field "created_at" string)
        (field "updated_at" string)
        (field "forks" int)
        (field "watchers" int)


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
        [ width 500
        , height 500
        , style "border" "2px solid #fff"
        , style "margin" "5px"
        , style "text-align" "center"
        , style "border-radius" "15px"
        , style "overflow" "hidden"
        ]
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
        , p []
            [ viewFromInt repo.forks (((\a -> a ++ " fork") >> addS repo.forks) >> text) ]
        , p []
            [ viewFromInt repo.watchers (((\a -> a ++ " watcher") >> addS repo.forks) >> text) ]
        , p []
            [ viewFromInt
                (repo.created_at |> getYear)
                ((\a -> "created_at: " ++ a) >> text)
            ]
        , p []
            [ viewFromInt
                (repo.updated_at |> getYear)
                ((\a -> "updated_at : " ++ a) >> text)
            ]
        , case repo.homepage of
            Just hp ->
                if hp /= "" then
                    a [ href hp, target "_blank", rel "noopener noreferrer" ] [ text "view live" ]

                else
                    text ""

            Nothing ->
                text ""
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
