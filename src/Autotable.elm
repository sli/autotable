module Autotable exposing (..)

import Browser
import Html exposing (Html, a, div, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import PageCss exposing (pageCss)
import Tuple exposing (first, second)


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


init : List (Column a) -> List a -> Model a
init columns data =
    { columns = columns, data = data, sorting = [] }


update : Msg -> Model a -> Model a
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
            { model | sorting = sorting, data = data }


view : Model a -> (Msg -> msg) -> Html msg
view model toMsg =
    let
        headerCells =
            List.map
                (\c ->
                    let
                        sorting =
                            case findSorting model.sorting c.label of
                                Just s ->
                                    case second s of
                                        Asc ->
                                            "(Asc)"

                                        Desc ->
                                            "(Desc)"

                                Nothing ->
                                    ""
                    in
                    th [ onClick <| toMsg <| Sort c.label ] [ text <| c.label ++ " " ++ sorting ]
                )
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
    div []
        [ pageCss
        , table
            [ class "w-full" ]
            [ thead
                [ class "bg-gray-900 text-white" ]
                [ tr [] headerCells ]
            , tbody [] bodyRows
            ]
        ]
