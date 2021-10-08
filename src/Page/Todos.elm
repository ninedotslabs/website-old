module Page.Todos exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as JD
import Json.Encode as JE
import Template exposing (..)
import Toasty
import Toasty.Defaults



-- MODEL


type alias Todo =
    { id : Int
    , name : String
    , url : String
    , isDone : Bool
    }


type alias FormTodo =
    { name : String
    , isDone : Bool
    }


type alias Model =
    { title : String
    , todos : Maybe (List Todo)
    , formItem : FormTodo
    , toasties : Toasty.Stack Toasty.Defaults.Toast
    }


type Msg
    = AddTodo FormTodo
    | UpdateTodo Todo
    | DeleteTodo Int
    | ClearTodos
    | FormTodoName String
    | FormTodoIsDone Bool
    | ClearForm
    | GotTodos (Result Http.Error (List Todo))
    | SaveTodo
    | ToastyMsg (Toasty.Msg Toasty.Defaults.Toast)



-- DECODER


todoDecoder : JD.Decoder Todo
todoDecoder =
    JD.map4 Todo
        (JD.field "id" JD.int)
        (JD.field "name" JD.string)
        (JD.field "url" JD.string)
        (JD.field "isDone" JD.bool)


todosDecoder : JD.Decoder (List Todo)
todosDecoder =
    JD.list todoDecoder


decodeTodos : String -> Maybe (List Todo)
decodeTodos todoJson =
    JD.decodeString todosDecoder todoJson
        |> Result.map Just
        |> Result.withDefault Nothing


todoEncoder : Todo -> JE.Value
todoEncoder todo =
    JE.object
        [ ( "id", JE.int todo.id )
        , ( "name", JE.string todo.name )
        , ( "url", JE.string todo.url )
        , ( "isDone", JE.bool todo.isDone )
        ]



-- STATE


myConfig : Toasty.Config msg
myConfig =
    Toasty.Defaults.config
        |> Toasty.transitionOutDuration 100
        |> Toasty.delay 8000


initialModel : Model
initialModel =
    { title = "Todos"
    , todos = Nothing
    , formItem =
        { name = ""
        , isDone = False
        }
    , toasties = Toasty.initialState
    }


addToast : Toasty.Defaults.Toast -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
addToast toast ( model, cmd ) =
    Toasty.addToast myConfig ToastyMsg toast ( model, cmd )


addToastIfUnique : Toasty.Defaults.Toast -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
addToastIfUnique toast ( model, cmd ) =
    Toasty.addToastIfUnique myConfig ToastyMsg toast ( model, cmd )


addPersistentToast : Toasty.Defaults.Toast -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
addPersistentToast toast ( model, cmd ) =
    Toasty.addPersistentToast myConfig ToastyMsg toast ( model, cmd )


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, getTodos )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddTodo todo ->
            ( { model | todos = newTodos todo model.todos, formItem = initialModel.formItem }
            , Cmd.none
            )
                |> addToast (Toasty.Defaults.Success "Allright!" "Todo successfully created!")

        UpdateTodo todo ->
            ( { model
                | todos =
                    model.todos
                        |> Maybe.map
                            (List.map
                                (\item ->
                                    if item.id == todo.id then
                                        { item | isDone = not item.isDone }

                                    else
                                        item
                                )
                            )
              }
            , Cmd.none
            )
                |> addToast (Toasty.Defaults.Success "Allright!" "Todo successfully updated!")

        DeleteTodo id ->
            ( { model
                | todos = Maybe.map (\todos -> List.filter (\todo -> not (todo.id == id)) todos) model.todos
              }
            , Cmd.none
            )
                |> addToast (Toasty.Defaults.Success "Allright!" "Todos successfully deleted!")

        ClearTodos ->
            ( { model | todos = Nothing }, Cmd.none ) |> addToast (Toasty.Defaults.Success "Allright!" "Todos successfully cleared!")

        FormTodoName name ->
            ( { model | formItem = model.formItem |> setFormName name }, Cmd.none )

        FormTodoIsDone _ ->
            ( { model | formItem = model.formItem |> setFormIsDone }
            , Cmd.none
            )

        ClearForm ->
            ( let
                newFormItem =
                    { name = "", isDone = False }
              in
              { model | formItem = newFormItem }
            , Cmd.none
            )

        GotTodos result ->
            result
                |> Result.map (\todos -> ( { model | todos = Just todos }, Cmd.none ))
                |> Result.withDefault ( model, Cmd.none )

        SaveTodo ->
            model.todos
                |> Maybe.map
                    (\todos ->
                        ( model
                        , postTodos todos
                        )
                            |> addToast (Toasty.Defaults.Success "Allright!" "Todos successfully saved!")
                    )
                |> Maybe.withDefault
                    (( model, Cmd.none )
                        |> addToast (Toasty.Defaults.Error "Error!" "Failed to save todos, please add at least one todo!")
                    )

        ToastyMsg subMsg ->
            Toasty.update myConfig ToastyMsg subMsg model



-- HELPER


setFormName : String -> FormTodo -> FormTodo
setFormName v f =
    { f | name = v }


setFormIsDone : FormTodo -> FormTodo
setFormIsDone f =
    { f | isDone = not f.isDone }


newTodo : Int -> FormTodo -> Todo
newTodo id todo =
    { id = id, name = todo.name, url = "/", isDone = todo.isDone }


newTodos : FormTodo -> Maybe (List Todo) -> Maybe (List Todo)
newTodos todo maybeTodos =
    maybeTodos
        |> Maybe.map
            (\todos -> newTodo (List.length todos + 1) todo :: todos)



-- VIEW


view : Model -> Template.Meta Msg
view model =
    { title = model.title
    , header = []
    , attrs = []
    , children =
        [ div [ class "container" ]
            [ h2 [] [ text "Todos with Elm" ]
            , formTodo model
            , div [ class "todos" ]
                [ ul [] (viewMaybeTodos model.todos)
                ]
            , Toasty.view myConfig Toasty.Defaults.view ToastyMsg model.toasties
            ]
        ]
    }


renderToast : String -> Html Msg
renderToast toast =
    div [] [ text toast ]


viewMaybeTodos : Maybe (List Todo) -> List (Html Msg)
viewMaybeTodos maybeTodos =
    maybeTodos
        |> Maybe.map
            (\todos ->
                if List.length todos > 0 then
                    todos |> List.map renderTodo

                else
                    viewNoTodos "Zero Todos"
            )
        |> Maybe.withDefault (viewNoTodos "Null Todos")


viewNoTodos : String -> List (Html Msg)
viewNoTodos t =
    [ li [ class "noTodoItem" ] [ h3 [] [ text t ] ] ]


renderTodo : Todo -> Html Msg
renderTodo todo =
    li [ class "todoItem" ]
        [ a [ href todo.url, target "_blank", rel "noopener noreferrer" ]
            [ h3 []
                [ text todo.name
                ]
            ]
        , div [ style "display" "flex", style "justify-content" "space-evenly" ]
            [ button
                [ onClick <| UpdateTodo todo, class "todoInfo" ]
                [ text
                    (textIf todo.isDone)
                ]
            , button [ onClick <| DeleteTodo todo.id, type_ "button", class "todoInfo" ] [ text " 🗑" ]
            ]
        ]


formTodo : Model -> Html Msg
formTodo model =
    div [ class "form" ]
        [ Html.form [ AddTodo model.formItem |> onSubmit ]
            [ div [ style "display" "flex", style "flex-direction" "space-evenly" ]
                [ div [ style "width" "100%" ]
                    [ input [ type_ "text", placeholder "insert todo name...", value model.formItem.name, onInput FormTodoName, class "todo" ] []
                    , text (textIf (not (model.formItem.name == "")))
                    ]
                , div [ style "display" "flex", style "flex-direction" "space-evenly" ]
                    [ button [ onClick ClearTodos, type_ "button", class "todoInfo" ] [ text " 🚮" ]
                    , button [ onClick SaveTodo, type_ "button", class "todoInfo" ] [ text " 📝" ]
                    ]
                ]
            , button [ type_ "submit", style "display" "none" ] [ text "Submit" ]
            ]
        ]


textIf : Bool -> String
textIf t =
    if t then
        "✅"

    else
        "❌"



-- EFFECT


getTodos : Cmd Msg
getTodos =
    Http.get
        { url = "https://alfianguide-be.herokuapp.com/api/todos"
        , expect = Http.expectJson GotTodos todosDecoder
        }


postTodos : List Todo -> Cmd Msg
postTodos todos =
    Http.post
        { url = "https://alfianguide-be.herokuapp.com/api/todos"
        , body = Http.jsonBody <| JE.object [ ( "todos", JE.list todoEncoder todos ) ]
        , expect = Http.expectJson GotTodos todosDecoder
        }
