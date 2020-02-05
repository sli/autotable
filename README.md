# Autotable

An in-development datatable for Elm. The code is going to be a bit bad for a
while but the functionality should work as advertised regardless.

## Features

* Sorting
* Filtering
* Pagination
* Row selection
* Row editing
* Drag and drop reorderable columns
* No CSS, and therefore no opinion on how it looks. Bring your own styles
* Ability to enable/disable features
* A just-ok API!

## Half-Features (or Free Features?)

Some features are supported just due to the design of Elm applications. As the
signals sent by the table are piped into the table's `update` function by the
programmer using the table, additional features can be supplied to the table
without the table itself supporting them. Some examples:

* Updating the table data (it's in the table state as an `Array`)
* Remote sorting/filtering/pagination/etc., just return a `Cmd Msg` that can
  then dispatch a signal that will update the table

## Styling

The table itself does no styling beyond two column widths. To style the demo, I
use [elm-css](https://package.elm-lang.org/packages/rtfeldman/elm-css/latest/).
The table itself has the class `autotable`, so that can be used to style
anything within the table. Learn your CSS selectors if you haven't already.
There are also a few more class names in use that can (and should) be styled:

* `span.autotable__sort-indicator` - The up/down arrow that displays the
  sorting direction for a column.
* `div.autotable__pagination` - Container for the pagination buttons.
* `button.autotable__pagination-page` - The pagination buttons themselves.
* `button.autotable__pagination-active` - The pagination button for the current
  page.
* `th.autotable__column` - All standard column headers.
* `th.autotable__column-{key}` - Header cell for the column with the given `key`.
  Most likely to be used to set the column's width.
* `th.autotable__column-filter` - All column filter cells.
* `th.autotable__column-filter-{key}` - Filter input cell for the column with the
  given `key`. Should probably be set to the same width as the class above, if
  set.
* `th.autotable__checkbox-header` - Both checkbox header cells. Most likely used
  to set the column's width.
* `td.autotable__checkbox` - Checkbox cells.
* `th.autotable__actions-header` - Both action header cells (e.g. edit button).
  Most likely used to set the column's width.
* `th.autotable__actions` - Action cells.

## Todo

* Resizable columns
* Better documentation, even if usage is a bit awkward

## Running the Demo

`$ yarn && yarn start`

## Usage

Install from the package repository:

```bash
$ elm install sli/autotable
```

If you're going to use drag and drop columns, you'll need this Javascript:

```js
document.body.addEventListener('dragstart', e =>
  e.dataTransfer.setData('text/plain', null))
```

Here's a minimal example:

```elm
import Autotable as AT
import Autotable.Options exposing (..)

type Model =
  { tableState : AT.Model }

type Msg
  = TableMsg AT.Msg

options : Options
options =
    Options Sorting Filtering Selecting Dragging Editing (Pagination 10) (Fill 10)

{-| Ideally `data` and `columns` are defined somewhere. -}
init : () -> ( Model, Cmd Msg )
init _ =
  { tableState = AT.init "my-table" columns data options }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    TableMsg tableMsg ->
      ( { model | tableState = AT.update tableMsg model.tableState }, Cmd.none )

view : Model -> Html Msg
view model =
  div [] [ AT.view model.tableState TableMsg ]
```

For a more complete example, see the [basic one](examples/basic/src/Main.elm).
