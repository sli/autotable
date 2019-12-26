module Main exposing (..)

import Autotable as AT
import Browser
import Html exposing (Html, a, div, input, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, type_, value)
import Html.Events exposing (onClick)
import PageCss exposing (pageCss)
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


myColumns : List (AT.Column Msg Person)
myColumns =
    [ AT.Column
        "Name"
        "name"
        .name
        (\p -> input [ type_ "text", value p.name ] [])
        .name
        (stringFilter .name)
    , AT.Column
        "Age"
        "age"
        (\p -> String.fromInt p.age)
        (\p -> input [ type_ "text", value <| String.fromInt p.age ] [])
        (numberSort .age)
        (numberFilter .age)
    , AT.Column
        "Cats"
        "cats"
        (\p -> String.fromInt p.cats)
        (\p -> input [ type_ "text", value <| String.fromInt p.cats ] [])
        (numberSort .cats)
        (numberFilter .cats)
    ]


myData : List Person
myData =
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
    ]


type alias Model =
    { tableState : AT.Model Msg Person }


type Msg
    = NoOp
    | TableMsg AT.Msg


init : () -> ( Model, Cmd Msg )
init () =
    ( { tableState = AT.init myColumns myData }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        TableMsg tableMsg ->
            ( { model | tableState = AT.update tableMsg model.tableState }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ pageCss
        , div [] [ AT.view model.tableState TableMsg ]
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
