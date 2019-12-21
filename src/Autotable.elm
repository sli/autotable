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
    , key : String
    , render : a -> String
    , sortFn : List a -> List a
    , filterFn : List a -> String -> List a
    }


type RowMode
    = Viewing
    | Editing


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


zip : List a -> List b -> List ( a, b )
zip xs ys =
    List.map2 Tuple.pair xs ys


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


findColumn : List (Column a) -> String -> Maybe (Column a)
findColumn columns key =
    List.head <| List.filter (\c -> c.key == key) columns


findSorting : List Sorting -> String -> Direction
findSorting sorting key =
    case List.head <| List.filter (\s -> first s == key) sorting of
        Just s ->
            second s

        Nothing ->
            None


indexForColumn : String -> List (Column a) -> Maybe Int
indexForColumn key columns =
    case List.head <| List.filter (\( i, c ) -> c.key == key) <| List.indexedMap (\i c -> ( i, c )) columns of
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
                    findSorting model.sorting key |> stepDirection

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
                filters =
                    case s of
                        "" ->
                            List.filter (\f -> first f /= key) model.filters

                        _ ->
                            List.filter (\f -> first f /= key) model.filters ++ [ ( key, s ) ]
            in
            { model | filters = filters }

        DragStart target ->
            { model | dragging = Just target }

        DragEnd ->
            { model | dragging = Nothing }

        DragOver target ->
            -- TODO: I hate it, but it works for now. Find a better way.
            -- Read the Basic.Maybe docs, ya ding dong.
            case indexForColumn target model.columns of
                Just targetPosition ->
                    case model.dragging of
                        Just key ->
                            if key /= target then
                                case List.head <| List.filter (\c -> c.key == key) model.columns of
                                    Just column ->
                                        let
                                            cleaned =
                                                List.filter (\c -> c.key /= key) model.columns

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
        filtered =
            List.foldl
                (\f d ->
                    -- TODO: Investigate a better pattern as this function shows up a second time below.
                    let
                        filterFn =
                            case findColumn model.columns (first f) of
                                Just c ->
                                    c.filterFn

                                Nothing ->
                                    \_ _ -> d
                    in
                    filterFn d <| second f
                )
                model.data
                model.filters

        sorted =
            List.foldl
                (\s d ->
                    -- TODO: It's that function again.
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
                filtered
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
                    findSorting model.sorting c.key |> viewDirection
            in
            th
                [ onClick <| toMsg <| Sort c.key
                , onDragStart <| toMsg <| DragStart c.key
                , onDragEnd <| toMsg DragEnd
                , onDragOver <| toMsg <| DragOver c.key
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
            let
                inputHandler s =
                    toMsg <| Filter c.key s
            in
            th []
                [ input [ type_ "text", placeholder "Filter", onInput inputHandler ] []
                ]
        )
        model.columns


viewBodyRows : Model a -> List a -> List (Html msg)
viewBodyRows model data =
    let
        buildRow row =
            tr [] <|
                List.map
                    (\c -> td [ class "text-left" ] [ text <| c.render row ])
                    model.columns
    in
    List.map buildRow data


viewDirection : Direction -> String
viewDirection direction =
    case direction of
        Asc ->
            "▲"

        Desc ->
            "▼"

        None ->
            ""
