module Autotable exposing (..)

import Browser
import Html exposing (Html, a, div, span, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, style)
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
    , sortFn : List a -> List a
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
    case direction of
        Asc ->
            ( label, Desc )

        Desc ->
            ( label, Asc )


findSorting : List Sorting -> String -> Maybe Sorting
findSorting sorting label =
    List.head <| List.filter (\s -> first s == label) sorting


findColumn : List (Column a) -> String -> Maybe (Column a)
findColumn columns label =
    List.head <| List.filter (\c -> c.label == label) columns


setOrder : Direction -> List a -> List a
setOrder direction data =
    case direction of
        Asc ->
            data

        Desc ->
            List.reverse data


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
                                            \_ -> d
                            in
                            sortFn d |> setOrder (second s)
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
                                            "▲"

                                        Desc ->
                                            "▼"

                                Nothing ->
                                    " "
                    in
                    th [ onClick <| toMsg <| Sort c.label ]
                        [ text <| c.label
                        , span [ style "margin-left" "10px", style "font-size" "10pt" ] [ text sorting ]
                        ]
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
