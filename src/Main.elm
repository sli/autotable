module Main exposing (..)

import Browser
import DemoCss exposing (pageCss, tableDefaultCss, tableOldDefaultCss)
import Html exposing (Html, a, div, input, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, type_, value)
import Html.Events exposing (onClick, onInput)
import Options exposing (..)
import Table as AT
import Tuple exposing (first, second)


type alias Person =
    { name : String
    , age : Int
    , cats : Int
    }


stringSort : (Person -> String) -> Person -> String
stringSort fn d =
    fn d


numberSort : (Person -> Int) -> Person -> String
numberSort fn d =
    String.fromInt <| fn d


stringFilter : (Person -> String) -> Person -> String -> Bool
stringFilter fn d s =
    let
        ls =
            String.toLower s
    in
    String.startsWith ls <| String.toLower <| fn d


numberFilter : (Person -> Int) -> Person -> String -> Bool
numberFilter fn d s =
    String.startsWith s <| String.fromInt <| fn d


columns : List (AT.Column Msg Person)
columns =
    [ AT.Column
        "Name"
        "name"
        .name
        (\p i -> input [ type_ "text", value p.name, onInput <| Edit "name" i ] [])
        .name
        (stringFilter .name)
        (\r v -> { r | name = v })
    , AT.Column
        "Age"
        "age"
        (\p -> String.fromInt p.age)
        (\p i -> input [ type_ "text", value <| String.fromInt p.age, onInput <| Edit "age" i ] [])
        (numberSort .age)
        (numberFilter .age)
        (\r v ->
            case String.toInt v of
                Just age ->
                    { r | age = age }

                Nothing ->
                    r
        )
    , AT.Column
        "Cats"
        "cats"
        (\p -> String.fromInt p.cats)
        (\p i -> input [ type_ "text", value <| String.fromInt p.cats, onInput <| Edit "cats" i ] [])
        (numberSort .cats)
        (numberFilter .cats)
        (\r v ->
            case String.toInt v of
                Just cats ->
                    { r | cats = cats }

                Nothing ->
                    r
        )
    ]


data : List Person
data =
    [ Person "Bob" 30 2
    , Person "Jack" 30 1
    , Person "Jane" 31 2
    , Person "William" 31 3
    , Person "Jolene" 32 3
    , Person "Billy" 43 5
    , Person "Holly" 32 1
    , Person "Xavier" 33 1
    , Person "Jimmy" 35 0
    , Person "John" 34 0
    , Person "Ashley" 34 1
    , Person "Michael" 33 2
    , Person "Eva" 41 3
    , Person "Claire" 44 4
    , Person "Lindsay" 42 2
    , Person "Natalie" 40 4
    ]


options : Options
options =
    Options Sorting Filtering Selecting Dragging Editing (Pagination 5) (Fill 5)


type alias Model =
    { tableState : AT.Model Msg Person }


type Msg
    = NoOp
    | Edit String Int String
    | TableMsg AT.Msg


init : () -> ( Model, Cmd Msg )
init () =
    ( { tableState = AT.init columns data options }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        TableMsg tableMsg ->
            ( { model | tableState = AT.update tableMsg model.tableState }, Cmd.none )

        Edit key index value ->
            ( { model | tableState = AT.update (AT.Edit key index value) model.tableState }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ pageCss
        , tableOldDefaultCss
        , div [ class "container" ] [ AT.view model.tableState TableMsg ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
