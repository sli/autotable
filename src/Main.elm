module Main exposing (..)

import Browser
import Dict exposing (Dict)
import Html exposing (Html, a, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Tuple exposing (first, second)


type alias Person =
    { name : String
    , age : Int
    , cats : Int
    }


stringSort : (Person -> String) -> List Person -> Sorting -> List Person
stringSort fn data sorting =
    let
        sorted =
            List.sortBy fn data
    in
    case second sorting of
        Asc ->
            sorted

        Desc ->
            List.reverse sorted


numberSort : (Person -> Int) -> List Person -> Sorting -> List Person
numberSort fn data sorting =
    let
        sorted =
            List.sortBy fn data
    in
    case second sorting of
        Asc ->
            sorted

        Desc ->
            List.reverse sorted


myColumns : List (Column Person)
myColumns =
    [ Column "Name" (\p -> p.name) <| stringSort .name
    , Column "Age" (\p -> String.fromInt p.age) <| numberSort .age
    , Column "Cats" (\p -> String.fromInt p.cats) <| numberSort .cats
    ]


myData : List Person
myData =
    [ Person "A" 30 2
    , Person "B" 30 1
    , Person "C" 31 2
    , Person "D" 31 3
    , Person "E" 32 3
    , Person "F" 32 1
    , Person "G" 33 1
    ]



-- Table implementation starts here.


type Direction
    = Asc
    | Desc


type alias Sorting =
    ( String, Direction )


type alias Column a =
    { label : String
    , render : a -> String
    , sortFn : List a -> Sorting -> List a
    }


type alias Attributes a =
    { columns : List (Column a)
    , data : List a
    , sorting : List ( String, Direction )
    }


type alias Model a =
    { columns : List (Column a)
    , data : List a
    , sorting : List Sorting
    }


type Msg
    = Sort String


swapDirection : Sorting -> Sorting
swapDirection ( label, direction ) =
    if direction == Asc then
        ( label, Desc )

    else
        ( label, Asc )


findSorting : List Sorting -> String -> Maybe Sorting
findSorting sorting label =
    List.head <| List.filter (\s -> first s == label) sorting


findColumn : List (Column a) -> String -> Maybe (Column a)
findColumn columns label =
    List.head <| List.filter (\c -> c.label == label) columns


init : () -> ( Model Person, Cmd Msg )
init () =
    ( { columns = myColumns, data = myData, sorting = [] }, Cmd.none )


update : Msg -> Model a -> ( Model a, Cmd Msg )
update msg model =
    case msg of
        Sort key ->
            let
                dir =
                    case findSorting model.sorting key of
                        Just v ->
                            swapDirection v

                        Nothing ->
                            ( key, Asc )

                sorting =
                    List.filter (\s -> first s /= key) model.sorting ++ [ dir ]

                data =
                    List.foldl
                        (\s d ->
                            let
                                sortFn =
                                    case findColumn model.columns (first s) of
                                        Just c ->
                                            c.sortFn

                                        Nothing ->
                                            \_ _ -> d
                            in
                            sortFn d s
                        )
                        model.data
                        sorting
            in
            ({ model | sorting = sorting, data = data }, Cmd.none)


view : Model a -> Html Msg
view model =
    let
        headerCells =
            List.map
                (\c ->
                  let
                      sorting = case findSorting model.sorting c.label of
                        Just s ->
                          case second s of
                            Asc -> "(Asc)"
                            Desc -> "(Desc)"
                        Nothing -> ""
                  in
                      th [ onClick <| Sort c.label ] [ text <| c.label ++ " " ++ sorting ])
                model.columns

        buildRow row =
            List.map
                (\c -> td [ class "text-left" ] [ text (c.render row) ])
                model.columns

        bodyRows =
            List.map
                (\d -> tr [] (buildRow d))
                model.data
    in
    table
        [ class "w-full" ]
        [ thead
            [ class "bg-gray-900 text-white" ]
            [ tr [] headerCells ]
        , tbody [] bodyRows
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
