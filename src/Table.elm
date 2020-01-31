module Table exposing (..)

import Array exposing (Array)
import Html exposing (Attribute, Html, a, button, div, input, span, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (checked, class, draggable, placeholder, style, type_)
import Html.Events exposing (on, onCheck, onClick, onInput)
import Json.Decode as D
import Options exposing (..)
import Tuple exposing (first, second)


type Direction
    = Asc
    | Desc
    | None


type alias Sorting =
    ( String, Direction )


type alias Filter =
    ( String, String )


type alias Column msg a =
    { label : String
    , key : String
    , render : a -> String
    , editRender : a -> Int -> Html msg
    , sort : a -> String
    , filter : a -> String -> Bool
    , update : a -> String -> a
    }


type alias Model msg a =
    { columns : List (Column msg a)
    , data : Array a
    , sorting : List Sorting
    , filters : List Filter
    , dragging : Maybe String
    , editing : List Int
    , selections : List Int
    , page : Int
    , options : Options
    }


type Msg
    = Sort String
    | Filter String String
    | DragStart String
    | DragEnd
    | DragOver String
    | Drop
    | StartEdit Int
    | FinishEdit Int
    | Edit String Int String
    | NextPage
    | PrevPage
    | SetPage Int
    | ToggleSelection Int
    | ToggleSelectAll


zip : List a -> List b -> List ( a, b )
zip xs ys =
    List.map2 Tuple.pair xs ys


listInsert : List a -> Int -> a -> List a
listInsert data index item =
    List.concat
        [ List.take index data
        , [ item ]
        , List.drop index data
        ]


listContains : a -> List a -> Bool
listContains item list =
    case List.head <| List.filter (\i -> i == item) list of
        Just found ->
            True

        Nothing ->
            False


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


onToggleCheck : msg -> Attribute msg
onToggleCheck msg =
    on "input" <| D.succeed msg


stepDirection : Direction -> Direction
stepDirection direction =
    case direction of
        Asc ->
            Desc

        Desc ->
            None

        None ->
            Asc


findColumn : List (Column msg a) -> String -> Maybe (Column msg a)
findColumn columns key =
    List.head <| List.filter (\c -> c.key == key) columns


findSorting : List Sorting -> String -> Direction
findSorting sorting key =
    case List.head <| List.filter (\s -> first s == key) sorting of
        Just s ->
            second s

        Nothing ->
            None


indexForColumn : String -> List (Column msg a) -> Maybe Int
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


init : List (Column msg a) -> List a -> Options -> Model msg a
init columns data options =
    { dragging = Nothing
    , columns = columns
    , data = Array.fromList data
    , sorting = []
    , filters = []
    , editing = []
    , selections = []
    , page = 1
    , options = options
    }


update : Msg -> Model msg a -> Model msg a
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
            -- TODO: This is better than what was here before but still not
            -- great, in my option. Surely there's a cleaner way.
            case ( indexForColumn target model.columns, model.dragging ) of
                ( Just targetPosition, Just key ) ->
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

                _ ->
                    model

        Drop ->
            { model | dragging = Nothing }

        StartEdit index ->
            { model | editing = index :: model.editing }

        FinishEdit index ->
            { model | editing = List.filter (\i -> i /= index) model.editing }

        Edit key index value ->
            case findColumn model.columns key of
                Just column ->
                    case Array.get index model.data of
                        Just r ->
                            let
                                row =
                                    column.update r value
                            in
                            { model | data = Array.set index row model.data }

                        Nothing ->
                            model

                Nothing ->
                    model

        NextPage ->
            { model | page = model.page + 1 }

        PrevPage ->
            let
                page =
                    max 1 <| model.page - 1
            in
            { model | page = page }

        SetPage page ->
            { model | page = page }

        ToggleSelection index ->
            if listContains index model.selections then
                { model | selections = List.filter (\i -> i /= index) model.selections }

            else
                { model | selections = index :: model.selections }

        ToggleSelectAll ->
            if Array.length model.data == List.length model.selections then
                { model | selections = [] }

            else
                { model | selections = List.range 0 <| Array.length model.data - 1 }


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


view : Model msg a -> (Msg -> msg) -> Html msg
view model toMsg =
    let
        indexes =
            List.range 0 <| Array.length model.data - 1

        filteredIndexes =
            List.foldl
                (\f data ->
                    case findColumn model.columns (first f) of
                        Just c ->
                            List.filter
                                (\d ->
                                    case Array.get d model.data of
                                        Just r ->
                                            c.filter r <| second f

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
                            setOrder dir <| List.sortWith (sorter c.sort model.data) data

                        Nothing ->
                            data
                )
                filteredIndexes
                model.sorting

        headerRows =
            case filtering model.options of
                Filtering ->
                    [ tr [] <| viewHeaderCells model toMsg
                    , tr [] <| viewFilterCells model toMsg
                    ]

                NoFiltering ->
                    [ tr [] <| viewHeaderCells model toMsg ]
    in
    div []
        [ table
            [ class "autotable" ]
            [ thead []
                headerRows
            , tbody [] <| viewBodyRows model sortedIndexes toMsg
            ]
        , viewPagination model filteredIndexes toMsg
        ]


viewDirection : Direction -> String
viewDirection direction =
    case direction of
        Asc ->
            "▲"

        Desc ->
            "▼"

        None ->
            ""


headerCellAttrs : Model msg a -> (Msg -> msg) -> Column msg a -> List (Html.Attribute msg)
headerCellAttrs model toMsg c =
    List.concat
        [ case sorting model.options of
            Sorting ->
                [ onClick <| toMsg <| Sort c.key ]

            NoSorting ->
                []
        , case dragging model.options of
            Dragging ->
                [ onDragStart <| toMsg <| DragStart c.key
                , onDragEnd <| toMsg DragEnd
                , onDragOver <| toMsg <| DragOver c.key
                , draggable "true"
                , style "user-select" "none"
                ]

            NoDragging ->
                []
        , case ( dragging model.options, sorting model.options ) of
            ( Dragging, _ ) ->
                [ style "user-select" "none" ]

            ( _, Sorting ) ->
                [ style "user-select" "none" ]

            ( _, _ ) ->
                []
        , [ class <| "autotable__column autotable__column-" ++ c.key ]
        ]


viewHeaderCells : Model msg a -> (Msg -> msg) -> List (Html msg)
viewHeaderCells model toMsg =
    let
        makeAttrs =
            headerCellAttrs model toMsg

        headerCells =
            List.map
                (\c ->
                    let
                        sorting =
                            findSorting model.sorting c.key |> viewDirection
                    in
                    th
                        (makeAttrs c)
                        [ text <| c.label
                        , span [ class "autotable__sort-indicator" ] [ text sorting ]
                        ]
                )
                model.columns

        allSelected =
            Array.length model.data == List.length model.selections
    in
    List.concat
        [ case selecting model.options of
            Selecting ->
                [ th
                    [ style "width" "1%", class "autotable__checkbox-header" ]
                    [ input [ type_ "checkbox", onToggleCheck <| toMsg <| ToggleSelectAll, checked allSelected ] [] ]
                ]

            NoSelecting ->
                []
        , headerCells
        , case editing model.options of
            Editing ->
                [ th [ style "width" "5%", class "autotable__actions-header" ] [] ]

            NoEditing ->
                []
        ]


viewFilterCells : Model msg a -> (Msg -> msg) -> List (Html msg)
viewFilterCells model toMsg =
    let
        filterCells =
            List.map
                (\c ->
                    let
                        inputHandler s =
                            toMsg <| Filter c.key s
                    in
                    th
                        [ class <| "autotable__column-filter autotable__column-filter-" ++ c.key ]
                        [ input [ type_ "text", placeholder "Filter", onInput inputHandler ] [] ]
                )
                model.columns
    in
    List.concat
        [ case selecting model.options of
            Selecting ->
                [ th [ style "width" "1%", class "autotable__header-checkbox" ] [] ]

            NoSelecting ->
                []
        , filterCells
        , case editing model.options of
            Editing ->
                [ th [ style "width" "5%", class "autotable__header-actions" ] [] ]

            NoEditing ->
                []
        ]


viewBodyRows : Model msg a -> List Int -> (Msg -> msg) -> List (Html msg)
viewBodyRows model indexes toMsg =
    let
        window =
            case pagination model.options of
                Pagination pageSize ->
                    List.take pageSize <| List.drop (pageSize * (model.page - 1)) indexes

                NoPagination ->
                    indexes

        rows =
            List.filterMap (\i -> Array.get i model.data) window

        buildRow index row =
            let
                editSignal =
                    if listContains index model.editing then
                        FinishEdit

                    else
                        StartEdit
            in
            tr [] <|
                List.concat
                    [ case selecting model.options of
                        Selecting ->
                            [ td
                                [ class "autotable__checkbox" ]
                                [ input
                                    [ type_ "checkbox"
                                    , onToggleCheck <| toMsg <| ToggleSelection index
                                    , checked <| listContains index model.selections
                                    ]
                                    []
                                ]
                            ]

                        NoSelecting ->
                            []
                    , List.map
                        (\c ->
                            if listContains index model.editing then
                                viewEditRow c row index

                            else
                                viewDisplayRow c row
                        )
                        model.columns
                    , case editing model.options of
                        Editing ->
                            [ td
                                [ class "autotable__actions" ]
                                [ button [ onClick <| toMsg <| editSignal index ] [ text "Edit" ] ]
                            ]

                        NoEditing ->
                            []
                    ]
    in
    List.concat
        [ List.map2 buildRow window rows
        , case fill model.options of
            Fill fillAmt ->
                if List.length window < fillAmt then
                    let
                        count =
                            fillAmt - List.length window

                        colCount =
                            case editing model.options of
                                Editing ->
                                    List.length model.columns + 1

                                NoEditing ->
                                    List.length model.columns

                        emptyRow =
                            tr [ class "autotable__row-empty" ] <|
                                List.repeat colCount <|
                                    td [ class "autotable__cell-empty" ] []
                    in
                    List.repeat count emptyRow

                else
                    []

            NoFill ->
                []
        ]


viewDisplayRow : Column msg a -> a -> Html msg
viewDisplayRow column row =
    td [ class "text-left" ] [ text <| column.render row ]


viewEditRow : Column msg a -> a -> Int -> Html msg
viewEditRow column row index =
    td [ class "text-left editing" ] [ column.editRender row index ]


viewPaginationButton : Int -> (Msg -> msg) -> Int -> Html msg
viewPaginationButton activePage toMsg n =
    let
        page =
            n + 1

        classes =
            if page == activePage then
                "autotable__pagination-page autotable__pagination-active"

            else
                "autotable__pagination-page"
    in
    button
        [ class classes, onClick <| toMsg <| SetPage page ]
        [ text <| String.fromInt page ]


viewPagination : Model msg a -> List Int -> (Msg -> msg) -> Html msg
viewPagination model filteredIndexes toMsg =
    let
        length =
            List.length filteredIndexes

        numPages =
            case pagination model.options of
                Pagination pageSize ->
                    if modBy pageSize length == 0 then
                        length // pageSize

                    else
                        (length // pageSize) + 1

                NoPagination ->
                    0

        pageButtons =
            Array.toList <|
                Array.initialize numPages <|
                    viewPaginationButton model.page toMsg
    in
    div [ class "autotable__pagination" ] pageButtons
