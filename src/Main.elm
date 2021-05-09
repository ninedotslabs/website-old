module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html.Attributes exposing (href)
import Page.About as About
import Page.Error as Error
import Page.Home as Home
import Page.Members as Members
import Page.Repos as Repos
import Template
import Url
import Url.Parser exposing ((</>), (<?>), Parser, oneOf, s, top)


type Page
    = Home
    | About
    | NotFound
    | Members Members.Model
    | Repos Repos.Model


type alias Model =
    { key : Nav.Key
    , page : Page
    }


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
    load url
        { key = key
        , page = NotFound
        }


type Msg
    = Msg1
    | UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | MembersMsg Members.Msg
    | ReposMsg Repos.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        Msg1 ->
            ( model, Cmd.none )

        UrlRequested urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            load url model

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
            Template.view ReposMsg (Repos.view repos)



{- title = "Hello World"
   , body =
       [ h1 []
           [ text "Hello World" ]
       , text "The current URL is: "
       , b [] [ text (Url.toString model.url) ]
       , ul []
           [ viewLink "/home"
           , viewLink "/profile"
           , viewLink "/reviews/the-century-of-the-self"
           , viewLink "/reviews/public-opinion"
           , viewLink "/reviews/shah-of-shahs"
           ]
       ]
   }
-}


loadHome : Model -> ( Model, Cmd Msg )
loadHome model =
    ( { model | page = Home }
    , Cmd.none
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
        ]


load : Url.Url -> Model -> ( Model, Cmd Msg )
load url model =
    case Url.Parser.parse (routeParser model) url of
        Just router ->
            router

        Nothing ->
            ( { model | page = NotFound }
            , Cmd.none
            )
