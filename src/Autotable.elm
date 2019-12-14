module Autotable exposing (..)

import Html exposing (Html, a, div, span, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, style)
import Html.Events exposing (on, onClick)
import Json.Decode as D
import PageCss exposing (pageCss)
import Tuple exposing (first, second)


type Direction
    = Asc
    | Desc
    | None


type alias Sorting =
    ( String, Direction )


type alias Column a =
    { label : String
    , render : a -> String
    , sortFn : List a -> List a
    }

type Row a
  = Row a
  | Editing a

type alias Model a =
    { columns : List (Column a)
    , data : List a
    , sorting : List Sorting
    , dragging : Maybe String
    }


type Msg
    = Sort String
    | DragStart String
    | DragEnd
    | DragOver String
    | Drop


onDragStart : msg -> Html.Attribute msg
onDragStart msg =
    on "dragstart" <| D.succeed msg


onDragEnd : msg -> Html.Attribute msg
onDragEnd msg =
    on "dragend" <| D.succeed msg


onDragOver : msg -> Html.Attribute msg
onDragOver msg =
    on "dragover" <| D.succeed msg


onDrop : msg -> Html.Attribute msg
onDrop msg =
    on "drop" <| D.succeed msg


stepDirection : Direction -> Direction
stepDirection direction =
    case direction of
        Asc ->
            Desc

        Desc ->
            None

        None ->
            Asc


findSorting : List Sorting -> String -> Maybe Sorting
findSorting sorting label =
    List.head <| List.filter (\s -> first s == label) sorting


findColumn : List (Column a) -> String -> Maybe (Column a)
findColumn columns label =
    List.head <| List.filter (\c -> c.label == label) columns


indexForColumn : String -> List (Column a) -> Maybe Int
indexForColumn label columns =
    case List.head <| List.filter (\( i, c ) -> c.label == label) <| List.indexedMap (\i c -> ( i, c )) columns of
        Just ( i, _ ) ->
            Just i

        Nothing ->
            Nothing


setOrder : Direction -> List a -> List a
setOrder direction data =
    case direction of
        Desc ->
            List.reverse data

        _ ->
          data


init : List (Column a) -> List a -> Model a
init columns data =
    { dragging = Nothing, columns = columns, data = data, sorting = [] }


update : Msg -> Model a -> Model a
update msg model =
    case msg of
        Sort key ->
            let
                dir =
                    case findSorting model.sorting key of
                        Just v ->
                            stepDirection (second v)

                        Nothing ->
                            Asc
                sorting =
                  case dir of
                    None ->
                      List.filter (\s -> first s /= key) model.sorting

                    _ ->
                      List.filter (\s -> first s /= key) model.sorting ++ [ ( key, dir) ]
            in
            { model | sorting = sorting }

        DragStart target ->
            { model | dragging = Just target }

        DragEnd ->
            { model | dragging = Nothing }

        DragOver target ->
            -- I hate it, but it works for now.
            case indexForColumn target model.columns of
                Just targetPosition ->
                    case model.dragging of
                        Just label ->
                            if label /= target then
                                case List.head <| List.filter (\c -> c.label == label) model.columns of
                                    Just column ->
                                        let
                                            cleaned =
                                                List.filter (\c -> c.label /= label) model.columns

                                            columns =
                                                List.take targetPosition cleaned ++ [ column ] ++ List.drop targetPosition cleaned
                                        in
                                        { model | columns = columns }

                                    Nothing ->
                                        model

                            else
                                model

                        Nothing ->
                            model

                Nothing ->
                    model

        Drop ->
            { model | dragging = Nothing }


view : Model a -> (Msg -> msg) -> Html msg
view model toMsg =
    let
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
                model.sorting

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

                                        None ->
                                            ""

                                Nothing ->
                                    ""
                    in
                    th
                        [ onClick <| toMsg <| Sort c.label
                        , onDragStart <| toMsg <| DragStart c.label
                        , onDragEnd <| toMsg DragEnd
                        , onDragOver <| toMsg <| DragOver c.label
                        , Html.Attributes.draggable "true"
                        , style "user-select" "none"
                        ]
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
                (\d -> tr [] <| buildRow d)
                data
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
