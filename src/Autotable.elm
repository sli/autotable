module Autotable exposing (..)

import Array exposing (Array)
import Html exposing (Html, Attribute, a, div, input, span, table, tbody, td, text, th, thead, tr)
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
    , sortFn : a -> String
    , filterFn : a -> String -> Bool
    }


type RowMode
    = Viewing
    | Editing


type alias Model a =
    { columns : Array (Column a)
    , data : Array a
    , sorting : Array Sorting
    , filters : Array Filter
    , dragging : Maybe String
    }


type Msg
    = Sort String
    | Filter String String
    | DragStart String
    | DragEnd
    | DragOver String
    | Drop



-- | SetData (List a)


zip : List a -> List b -> List ( a, b )
zip xs ys =
    List.map2 Tuple.pair xs ys


arrayInsert : Array a -> Int -> a -> Array a
arrayInsert data index item =
    let
        head =
            Array.push item (Array.slice 0 index data)

        tail =
            Array.slice index (Array.length data) data
    in
    Array.append head tail


onDragStart : msg -> Attribute msg
onDragStart msg =
    on "dragstart" <| D.succeed msg


onDragEnd : msg -> Attribute msg
onDragEnd msg =
    on "dragend" <| D.succeed msg


onDragOver : msg -> Attribute msg
onDragOver msg =
    on "dragover" <| D.succeed msg


onDrop : msg -> Attribute msg
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


findColumn : Array (Column a) -> String -> Maybe (Column a)
findColumn columns key =
    Array.get 0 <| Array.filter (\c -> c.key == key) columns


findSorting : Array Sorting -> String -> Direction
findSorting sorting key =
    case Array.get 0 <| Array.filter (\s -> first s == key) sorting of
        Just s ->
            second s

        Nothing ->
            None


indexForColumn : String -> Array (Column a) -> Maybe Int
indexForColumn key columns =
    case Array.get 0 <| Array.filter (\( i, c ) -> c.key == key) <| Array.indexedMap (\i c -> ( i, c )) columns of
        Just ( i, _ ) ->
            Just i

        Nothing ->
            Nothing


setOrder : Direction -> Array a -> Array a
setOrder direction data =
    case direction of
        Desc ->
            Array.toList data |> List.reverse |> Array.fromList

        _ ->
            data


init : List (Column a) -> List a -> Model a
init columns data =
    { dragging = Nothing, columns = Array.fromList columns, data = Array.fromList data, sorting = Array.empty, filters = Array.empty }


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
                            Array.filter (\s -> first s /= key) model.sorting

                        _ ->
                            let
                                newSorting =
                                    Array.filter (\s -> first s /= key) model.sorting
                            in
                            Array.push ( key, dir ) newSorting
            in
            { model | sorting = sorting }

        Filter key s ->
            let
                filters =
                    case s of
                        "" ->
                            Array.filter (\f -> first f /= key) model.filters

                        _ ->
                            let
                                newFilters =
                                    Array.filter (\f -> first f /= key) model.filters
                            in
                            Array.push ( key, s ) newFilters
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
                                case Array.get 0 <| Array.filter (\c -> c.key == key) model.columns of
                                    Just column ->
                                        let
                                            cleaned =
                                                Array.filter (\c -> c.key /= key) model.columns

                                            columns =
                                                arrayInsert cleaned targetPosition column
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



-- SetData data ->
--     { model | data = Array.fromList data }


view : Model a -> (Msg -> msg) -> Html msg
view model toMsg =
    let
        filtered =
            Array.foldl
                (\f data ->
                    -- TODO: Investigate a better pattern as this function shows up a second time below.
                    let
                        filterFn =
                            case findColumn model.columns (first f) of
                                Just c ->
                                    c.filterFn

                                Nothing ->
                                    \_ _ -> True
                    in
                    Array.filter (\d -> filterFn d <| second f) data
                )
                model.data
                model.filters

        sorted =
            filtered

        -- sorted =
        --     Array.foldl
        --         (\s data ->
        --             -- TODO: It's that function again.
        --             let
        --                 sortFn =
        --                     case findColumn model.columns (first s) of
        --                         Just c ->
        --                             c.sortFn
        --
        --                         Nothing ->
        --                             \_ -> data
        --
        --                 dir =
        --                     second s
        --             in
        --             setOrder dir <| Array.fromList <| List.sortBy (\d -> sortFn d) <| Array.toList data
        --         )
        --         filtered
        --         model.sorting
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
    let
        headerCells =
            Array.map
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
    in
    Array.toList headerCells


viewFilterCells : Model a -> (Msg -> msg) -> List (Html msg)
viewFilterCells model toMsg =
    let
        filterCells =
            Array.map
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
    in
    Array.toList filterCells


viewBodyRows : Model a -> Array a -> List (Html msg)
viewBodyRows model data =
    let
        buildRow row =
            tr [] <|
                Array.toList <|
                    Array.map
                        (\c -> td [ class "text-left" ] [ text <| c.render row ])
                        model.columns
    in
    Array.toList <| Array.map buildRow data


viewDirection : Direction -> String
viewDirection direction =
    case direction of
        Asc ->
            "▲"

        Desc ->
            "▼"

        None ->
            ""
