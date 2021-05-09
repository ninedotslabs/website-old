module Page.Repos exposing (Entries(..), Model, Msg(..), Repo, Repos, getRepos, init, renderRepo, repoDecoder, reposDecoder, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as JD exposing (Decoder, field, string)
import Template exposing (..)
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
    }


type alias Repos =
    List Repo


type Msg
    = Reload
    | GotRepos (Result Http.Error Repos)



-- DECODER


repoDecoder : Decoder Repo
repoDecoder =
    JD.map3 Repo
        (field "name" string)
        (JD.maybe (field "description" string))
        (field "html_url" string)


reposDecoder : Decoder Repos
reposDecoder =
    JD.list repoDecoder


init : () -> ( Model, Cmd Msg )
init _ =
    ( { title = "Members", entries = Loading }, getRepos apiGHOrgRepos )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Reload ->
            ( { model | entries = Loading }, getRepos apiGHOrgRepos )

        GotRepos result ->
            case result of
                Ok repos ->
                    ( { model | entries = Success repos }, Cmd.none )

                Err _ ->
                    ( { model | entries = Failure }, Cmd.none )



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
                    [ p [ style "margin" "3rem 0px 10px 0px" ] [ text "Error loading repos." ]
                    , button
                        [ onClick Reload
                        , style "margin" "10px 5px"
                        , style "border" "2px solid #589bd5"
                        , style "padding" "10px"
                        , style "border-radius" "15px"
                        , style "cursor" "pointer"
                        ]
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
                    [ p [ style "margin" "3rem 0px 10px 0px" ] [ text "Loading repos..." ] ]
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
                        (List.map renderRepo repos)
                    ]
                ]
            }


renderRepo : Repo -> Html Msg
renderRepo repo =
    div
        [ width 150
        , height 200
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
                (case repo.description of
                    Just a ->
                        a

                    Nothing ->
                        ""
                )
            ]
        ]


getRepos : String -> Cmd Msg
getRepos url =
    Http.get
        { url = url
        , expect = Http.expectJson GotRepos reposDecoder
        }
