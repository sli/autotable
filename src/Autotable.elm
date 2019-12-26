module Autotable exposing (..)

import Array exposing (Array)
import Html exposing (Attribute, Html, a, button, div, input, span, table, tbody, td, text, th, thead, tr)
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


type alias Column a msg =
    { label : String
    , key : String
    , render : a -> String
    , editRender : a -> Html msg
    , sortFn : a -> String
    , filterFn : a -> String -> Bool
    }


type RowMode
    = Viewing
    | Editing


type alias Model a msg =
    { columns : List (Column a msg)
    , data : Array a
    , sorting : List Sorting
    , filters : List Filter
    , dragging : Maybe String
    , editing : List Int
    }


type Msg
    = Sort String
    | Filter String String
    | DragStart String
    | DragEnd
    | DragOver String
    | Drop
    | ToggleEdit Int



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


listInsert : List a -> Int -> a -> List a
listInsert data index item =
    List.concat
        [ List.take index data
        , [ item ]
        , List.drop (index + 1) data
        ]


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


findColumn : List (Column a msg) -> String -> Maybe (Column a msg)
findColumn columns key =
    List.head <| List.filter (\c -> c.key == key) columns


findSorting : List Sorting -> String -> Direction
findSorting sorting key =
    case List.head <| List.filter (\s -> first s == key) sorting of
        Just s ->
            second s

        Nothing ->
            None


indexForColumn : String -> List (Column a msg) -> Maybe Int
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


init : List (Column a msg) -> List a -> Model a msg
init columns data =
    { dragging = Nothing, columns = columns, data = Array.fromList data, sorting = [], filters = [], editing = [] }


update : Msg -> Model a msg -> Model a msg
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
                            let
                                newSorting =
                                    List.filter (\s -> first s /= key) model.sorting
                            in
                            List.append newSorting [ ( key, dir ) ]
            in
            { model | sorting = sorting }

        Filter key s ->
            let
                filters =
                    case s of
                        "" ->
                            List.filter (\f -> first f /= key) model.filters

                        _ ->
                            let
                                newFilters =
                                    List.filter (\f -> first f /= key) model.filters
                            in
                            List.append newFilters [ ( key, s ) ]
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
                                                listInsert cleaned targetPosition column
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

        ToggleEdit index ->
            case List.head <| List.filter (\i -> i == index) model.editing of
                Just found ->
                    { model | editing = List.filter (\i -> i /= index) model.editing }

                Nothing ->
                    { model | editing = index :: model.editing }



-- SetData data ->
--     { model | data = Array.fromList data }


sorter : (a -> String) -> Array a -> Int -> Int -> Order
sorter sortFn data a b =
    let
        ca =
            case Array.get a data of
                Just r ->
                    sortFn r

                Nothing ->
                    ""

        cb =
            case Array.get b data of
                Just r ->
                    sortFn r

                Nothing ->
                    ""
    in
    compare ca cb


view : Model a msg -> (Msg -> msg) -> Html msg
view model toMsg =
    let
        indexes =
            Array.initialize (Array.length model.data) identity

        filteredIndexes =
            List.foldl
                (\f data ->
                    case findColumn model.columns (first f) of
                        Just c ->
                            Array.filter
                                (\d ->
                                    case Array.get d model.data of
                                        Just r ->
                                            c.filterFn r <| second f

                                        Nothing ->
                                            False
                                )
                                data

                        Nothing ->
                            data
                )
                indexes
                model.filters

        sortedIndexes =
            List.foldl
                (\s data ->
                    let
                        dir =
                            second s
                    in
                    case findColumn model.columns (first s) of
                        Just c ->
                            setOrder dir <| List.sortWith (sorter c.sortFn model.data) data

                        Nothing ->
                            data
                )
                (Array.toList filteredIndexes)
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
            , tbody [] <| viewBodyRows model sortedIndexes toMsg
            ]
        ]


viewHeaderCells : Model a msg -> (Msg -> msg) -> List (Html msg)
viewHeaderCells model toMsg =
    let
        headerCells =
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
    in
    List.append headerCells [ th [ style "width" "5%" ] [] ]


viewFilterCells : Model a msg -> (Msg -> msg) -> List (Html msg)
viewFilterCells model toMsg =
    let
        filterCells =
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
    in
    List.append filterCells [ th [ style "width" "5%" ] [] ]


viewBodyRows : Model a msg -> List Int -> (Msg -> msg) -> List (Html msg)
viewBodyRows model indexes toMsg =
    let
        rows =
            List.filterMap (\i -> Array.get i model.data) indexes

        buildRow index row =
            tr [] <|
                List.map
                    (\c -> td [ class "text-left" ] [ text <| c.render row ])
                    model.columns
                    ++ [ td [] [ button [ onClick <| toMsg <| ToggleEdit index ] [ text "Edit" ] ] ]
    in
    List.indexedMap buildRow rows


viewDirection : Direction -> String
viewDirection direction =
    case direction of
        Asc ->
            "▲"

        Desc ->
            "▼"

        None ->
            ""
