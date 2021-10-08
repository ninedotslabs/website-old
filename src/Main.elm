module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html.Attributes exposing (href)
import Page.About as About
import Page.Error as Error
import Page.Home as Home
import Page.Members as Members
import Page.Repos as Repos
import Page.Todos as Todos
import Template
import Url
import Url.Parser exposing ((</>), (<?>), Parser, oneOf, s, top)


type Page
    = Home
    | About
    | NotFound
    | Members Members.Model
    | Repos Repos.Model
    | Todos Todos.Model


type alias Model =
    { key : Nav.Key
    , page : Page
    }


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | MembersMsg Members.Msg
    | ReposMsg Repos.Msg
    | TodosMsg Todos.Msg


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


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Browser.Document Msg
view model =
    case model.page of
        Home ->
            Template.view never Home.view

        About ->
            Template.view never About.view

        NotFound ->
            Template.view never
                { title = "Not Found"
                , header = []
                , attrs = []
                , children = Error.notFound
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
