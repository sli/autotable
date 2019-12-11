module Main exposing (..)

import Autotable as AT
import Browser
import Html exposing (Html, a, div, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import PageCss exposing (pageCss)
import Tuple exposing (first, second)


type alias Person =
    { name : String
    , age : Int
    , cats : Int
    }


stringSort : (Person -> String) -> List Person -> List Person
stringSort fn data =
    List.sortBy fn data


numberSort : (Person -> Int) -> List Person -> List Person
numberSort fn data =
    List.sortBy fn data


myColumns : List (AT.Column Person)
myColumns =
    [ AT.Column "Name" (\p -> p.name) <| stringSort .name
    , AT.Column "Age" (\p -> String.fromInt p.age) <| numberSort .age
    , AT.Column "Cats" (\p -> String.fromInt p.cats) <| numberSort .cats
    ]


myData : List Person
myData =
    [ Person "Bob" 30 2
    , Person "Dick" 30 1
    , Person "Jane" 31 2
    , Person "William" 31 3
    , Person "Jolene" 32 3
    , Person "Holly" 32 1
    , Person "Xavier" 33 1
    ]


type alias Model a =
    { tableState : AT.Model a }


type Msg
    = NoOp
    | TableMsg AT.Msg


init : () -> ( Model Person, Cmd Msg )
init () =
    ( { tableState = AT.init myColumns myData }, Cmd.none )


update : Msg -> Model a -> ( Model a, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        TableMsg tableMsg ->
            ( { model | tableState = AT.update tableMsg model.tableState }, Cmd.none )


view : Model a -> Html Msg
view model =
    div []
        [ pageCss
        , div [] [ AT.view model.tableState TableMsg ]
        ]


subscriptions : Model a -> Sub Msg
subscriptions model =
    Sub.none


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
