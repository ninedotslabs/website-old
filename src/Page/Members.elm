module Page.Members exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as JD exposing (Decoder, field, string)
import Template
import Utils.Endpoint exposing (apiGHOrgMembers)


type alias Model =
    { title : String
    , entries : Entries
    }


type Entries
    = Failure
    | Loading
    | Success Members


type alias Member =
    { login : String
    , avatar_url : String
    , html_url : String
    }


type alias Members =
    List Member


type Msg
    = Reload
    | GotMembers (Result Http.Error Members)



-- DECODER


memberDecoder : Decoder Member
memberDecoder =
    JD.map3 Member
        (field "login" string)
        (field "avatar_url" string)
        (field "html_url" string)


membersDecoder : Decoder Members
membersDecoder =
    JD.list memberDecoder


init : () -> ( Model, Cmd Msg )
init _ =
    ( { title = "Members", entries = Loading }, getMembers apiGHOrgMembers )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Reload ->
            ( { model | entries = Loading }, getMembers apiGHOrgMembers )

        GotMembers result ->
            case result of
                Ok members ->
                    ( { model | entries = Success members }, Cmd.none )

                Err _ ->
                    ( { model | entries = Failure }, Cmd.none )


view : Model -> Template.Meta Msg
view model =
    case model.entries of
        Failure ->
            { title = model.title
            , header = []
            , attrs = []
            , children =
                [ div [ style "text-align" "center" ]
                    [ p [ style "margin" "3rem 0px 10px 0px" ] [ text "Error loading members." ]
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
                    [ p [ style "margin" "3rem 0px 10px 0px" ] [ text "Loading members..." ] ]
                ]
            }

        Success members ->
            { title = model.title
            , header = []
            , attrs = []
            , children =
                [ div [ class "container" ]
                    [ h2 [] [ text "Anggota" ]
                    , div
                        [ class "member" ]
                        (List.map renderMember members)
                    ]
                ]
            }



-- VIEW
{-
   componentMembers : Model -> Html Msg
   componentMembers model =
       div [ style "padding" "10px", style "background-color" "#334455", style "color" "#fff" ]
           [ h2 [ style "text-align" "center" ] [ text "Members" ]
           , viewMembers model
           ]
-}


renderMember : Member -> Html Msg
renderMember member =
    div
        [ width 150
        , height 200
        , class "card"
        ]
        [ img [ src member.avatar_url, alt member.login, title member.login, width 150, height 150 ] []
        , a
            [ href member.html_url
            , target "_blank"
            , rel "noopener noreferrer"
            , style "text-decoration" "none"
            ]
            [ h3 [ style "margin" "5px 0px" ] [ text member.login ] ]
        ]



-- HTTP


getMembers : String -> Cmd Msg
getMembers url =
    Http.get
        { url = url
        , expect = Http.expectJson GotMembers membersDecoder
        }
