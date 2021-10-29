port module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, button, div, h1, h2, h3, img, input, p, text)
import Html.Attributes exposing (href, placeholder, src, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode
import Json.Decode.Pipeline
import Json.Encode
import Page.About as About
import Page.Error as Error
import Page.Home as Home
import Page.Members as Members
import Page.Repos as Repos
import Page.Todos as Todos
import Template
import Url
import Url.Parser exposing ((</>), (<?>), Parser, oneOf, s, top)


port signIn : () -> Cmd msg


port signInInfo : (Json.Encode.Value -> msg) -> Sub msg


port signInError : (Json.Encode.Value -> msg) -> Sub msg


port signOut : () -> Cmd msg


type Page
    = Home
    | About
    | NotFound
    | Members Members.Model
    | Repos Repos.Model
    | Todos Todos.Model


type alias ErrorData =
    { code : Maybe String, message : Maybe String, credential : Maybe String }


type alias UserData =
    { token : String, email : String, uid : String }


type alias Model =
    { key : Nav.Key
    , page : Page
    , userData : Maybe UserData
    , error : ErrorData
    }


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | MembersMsg Members.Msg
    | ReposMsg Repos.Msg
    | TodosMsg Todos.Msg
    | LogIn
    | LogOut
    | LoggedInData (Result Json.Decode.Error UserData)
    | LoggedInError (Result Json.Decode.Error ErrorData)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = UrlRequested
        , onUrlChange = UrlChanged
        }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    route url
        { key = key
        , page = NotFound
        , userData = Nothing
        , error = emptyError
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        UrlRequested urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            route url model

        MembersMsg msg ->
            case model.page of
                Members members ->
                    loadMembers model (Members.update msg members)

                _ ->
                    ( model, Cmd.none )

        ReposMsg msg ->
            case model.page of
                Repos repos ->
                    loadRepos model (Repos.update msg repos)

                _ ->
                    ( model, Cmd.none )

        TodosMsg msg ->
            case model.page of
                Todos todos ->
                    loadTodos model (Todos.update msg todos)

                _ ->
                    ( model, Cmd.none )

        LogIn ->
            ( model, signIn () )

        LogOut ->
            ( { model | userData = Maybe.Nothing, error = emptyError }, signOut () )

        LoggedInData result ->
            case result of
                Ok value ->
                    ( { model | userData = Just value }, Cmd.none )

                Err error ->
                    ( { model | error = messageToError <| Json.Decode.errorToString error }, Cmd.none )

        LoggedInError result ->
            case result of
                Ok value ->
                    ( { model | error = value }, Cmd.none )

                Err error ->
                    ( { model | error = messageToError <| Json.Decode.errorToString error }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ signInInfo (Json.Decode.decodeValue userDataDecoder >> LoggedInData)
        , signInError (Json.Decode.decodeValue logInErrorDecoder >> LoggedInError)
        ]


view : Model -> Browser.Document Msg
view model =
    case model.page of
        Home ->
            Template.view never Home.view

        About ->
            Template.view never About.view

        NotFound ->
            { title = "NOT FOUND"
            , body =
                [ case model.userData of
                    Just data ->
                        button [ onClick LogOut ] [ text "Logout from Google" ]

                    Maybe.Nothing ->
                        button [ onClick LogIn ] [ text "Login with Google" ]
                , h2 []
                    [ text <|
                        case model.userData of
                            Just data ->
                                data.email ++ " " ++ data.uid ++ " " ++ data.token

                            Maybe.Nothing ->
                                ""
                    ]
                ]
            }

        Members members ->
            Template.view MembersMsg (Members.view members)

        Repos repos ->
            Repos.view repos |> Template.view ReposMsg

        Todos todos ->
            Todos.view todos |> Template.view TodosMsg


loadHome : Model -> ( Model, Cmd Msg )
loadHome model =
    ( { model | page = Home }
    , Cmd.none
    )


loadTodos : Model -> ( Todos.Model, Cmd Todos.Msg ) -> ( Model, Cmd Msg )
loadTodos model ( todos, cmds ) =
    ( { model | page = Todos todos }
    , Cmd.map TodosMsg cmds
    )


loadMembers : Model -> ( Members.Model, Cmd Members.Msg ) -> ( Model, Cmd Msg )
loadMembers model ( members, cmds ) =
    ( { model | page = Members members }
    , Cmd.map MembersMsg cmds
    )


loadRepos : Model -> ( Repos.Model, Cmd Repos.Msg ) -> ( Model, Cmd Msg )
loadRepos model ( repos, cmds ) =
    ( { model | page = Repos repos }
    , Cmd.map ReposMsg cmds
    )


path : Parser a b -> a -> Parser (b -> c) c
path parser handler =
    Url.Parser.map handler parser


routeParser : Model -> Parser (( Model, Cmd Msg ) -> c) c
routeParser model =
    oneOf
        [ path top (loadHome model)
        , path (s "home") (loadHome model)
        , path (s "about")
            ( { model | page = About }
            , Cmd.none
            )
        , path (s "members")
            (loadMembers model (Members.init ()))
        , path (s "repos")
            (loadRepos model (Repos.init ()))
        , path (s "todos")
            (loadTodos model (Todos.init ()))
        ]


route : Url.Url -> Model -> ( Model, Cmd Msg )
route url model =
    Url.Parser.parse (routeParser model) url
        |> Maybe.map (\a -> a)
        |> Maybe.withDefault
            ( { model | page = NotFound }
            , Cmd.none
            )


userDataDecoder : Json.Decode.Decoder UserData
userDataDecoder =
    Json.Decode.succeed UserData
        |> Json.Decode.Pipeline.required "token" Json.Decode.string
        |> Json.Decode.Pipeline.required "email" Json.Decode.string
        |> Json.Decode.Pipeline.required "uid" Json.Decode.string


logInErrorDecoder : Json.Decode.Decoder ErrorData
logInErrorDecoder =
    Json.Decode.succeed ErrorData
        |> Json.Decode.Pipeline.required "code" (Json.Decode.nullable Json.Decode.string)
        |> Json.Decode.Pipeline.required "message" (Json.Decode.nullable Json.Decode.string)
        |> Json.Decode.Pipeline.required "credential" (Json.Decode.nullable Json.Decode.string)


messageToError : String -> ErrorData
messageToError message =
    { code = Maybe.Nothing, credential = Maybe.Nothing, message = Just message }


emptyError : ErrorData
emptyError =
    { code = Maybe.Nothing, credential = Maybe.Nothing, message = Maybe.Nothing }
