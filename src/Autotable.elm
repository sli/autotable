module Autotable exposing (..)

import Html exposing (Html, a, div, input, span, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, placeholder, style, type_)
import Html.Events exposing (on, onClick, onInput)
import Json.Decode as D
import PageCss exposing (pageCss)
import Tuple exposing (first, second)


type Direction
    = Asc
    | Desc
    | None


type alias Sorting =
    ( String, Direction )


type alias Filter =
    ( String, String )


type alias Column a =
    { label : String
    , render : a -> String
    , sortFn : List a -> List a
    , filterFn : List a -> String -> List a
    }


type Row a
    = Row a
    | Editing a


type alias Model a =
    { columns : List (Column a)
    , data : List a
    , sorting : List Sorting
    , filters : List Filter
    , dragging : Maybe String
    }


type Msg
    = Sort String
    | Filter String String
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


findFilter : List (Column a) -> List Filter -> String -> Maybe Filter
findFilter columns filters label =
    case findColumn columns label of
        Just c ->
            List.head <| List.filter (\f -> first f == c.label) filters

        Nothing ->
            Nothing


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
    { dragging = Nothing, columns = columns, data = data, sorting = [], filters = [] }


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
                            List.filter (\s -> first s /= key) model.sorting ++ [ ( key, dir ) ]
            in
            { model | sorting = sorting }

        Filter key s ->
            let
                -- filters =
                --     List.filter (\f -> first f /= key) model.filters ++ [ ( key, s ) ]

                filters =
                    model.filters
            in
            { model | filters = filters }

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
        sorted =
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
    in
    div []
        [ pageCss
        , table
            [ class "w-full" ]
            [ thead
                [ class "bg-gray-900 text-white" ]
                [ tr [] <| viewHeaderCells model toMsg
                , tr [] <| viewFilterCells model toMsg
                ]
            , tbody [] <| viewBodyRows model sorted
            ]
        ]


viewHeaderCells : Model a -> (Msg -> msg) -> List (Html msg)
viewHeaderCells model toMsg =
    List.map
        (\c ->
            let
                sorting =
                    case findSorting model.sorting c.label of
                        Just s ->
                            viewDirection <| second s

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
                , span [ class "sort-indicator" ] [ text sorting ]
                ]
        )
        model.columns


viewFilterCells : Model a -> (Msg -> msg) -> List (Html msg)
viewFilterCells model toMsg =
    List.map
        (\c ->
            th []
                [ input [ type_ "text", placeholder "Filter" ] []
                ]
        )
        model.columns


viewBodyRows : Model a -> List a -> List (Html msg)
viewBodyRows model data =
    let
        buildRow row =
            List.map
                (\c -> td [ class "text-left" ] [ text <| c.render row ])
                model.columns
    in
    List.map
        (\d -> tr [] <| buildRow d)
        data


viewDirection : Direction -> String
viewDirection direction =
    case direction of
        Asc ->
            "▲"

        Desc ->
            "▼"

        None ->
            ""
