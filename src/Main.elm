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


stringFilter : (Person -> String) -> List Person -> String -> List Person
stringFilter fn data s =
    let
        ls =
            String.toLower s
    in
    List.filter (\d -> String.startsWith ls <| String.toLower <| fn d) data


numberFilter : (Person -> Int) -> List Person -> String -> List Person
numberFilter fn data s =
    List.filter
        (\d -> String.startsWith s <| String.fromInt <| fn d)
        data


myColumns : List (AT.Column Person)
myColumns =
    [ AT.Column "Name" (\p -> p.name) (stringSort .name) (stringFilter .name)
    , AT.Column "Age" (\p -> String.fromInt p.age) (numberSort .age) (numberFilter .age)
    , AT.Column "Cats" (\p -> String.fromInt p.cats) (numberSort .cats) (numberFilter .cats)
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
