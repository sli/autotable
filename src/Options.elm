module Options exposing (..)


type SortingOption
    = Sorting
    | NoSorting


type FilteringOption
    = Filtering
    | NoFiltering


type SelectingOption
    = Selecting
    | NoSelecting


type DraggingOption
    = Dragging
    | NoDragging


type EditingOption
    = Editing
    | NoEditing


type PaginationOption
    = NoPagination
    | Pagination Int


type Options
    = Options SortingOption FilteringOption SelectingOption DraggingOption EditingOption PaginationOption


defaultOptions : Options
defaultOptions =
    Options Sorting Filtering Selecting Dragging Editing (Pagination 10)


sorting : Options -> SortingOption
sorting (Options s _ _ _ _ _) =
    s


filtering : Options -> FilteringOption
filtering (Options _ f _ _ _ _) =
    f


selecting : Options -> SelectingOption
selecting (Options _ _ s _ _ _) =
    s


dragging : Options -> DraggingOption
dragging (Options _ _ _ d _ _) =
    d


editing : Options -> EditingOption
editing (Options _ _ _ _ e _) =
    e


pagination : Options -> PaginationOption
pagination (Options _ _ _ _ _ p) =
    p
