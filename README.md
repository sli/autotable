![](logo.svg)

# Autotable

An in-development datatable for Elm. The code is going to be a bit bad for a
while but the functionality should work as advertised regardless. Strong types
are great.

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
* Documentation, even if usage is a bit awkward

## Running the Demo

`$ yarn install && yarn start`

## Usage

You mostly can't, for the time being, since it's not published. But if you
really want to, you can pull this code to use it. Just don't forget you'll need
a little Javascript. It can be found in `static/index.html`, but I'll put it
here, too.

```js
document.body.addEventListener('dragstart', e =>
  e.dataTransfer.setData('text/plain', null))
```

Here's a minimal example:

```elm
import Autotable as AT

type Model =
  { tableState : AT.Model }

type Msg
  = TableMsg AT.Msg

{-| Ideally `data` and `columns` are defined somewhere.
-}
init : () -> ( Model, Cmd Msg )
init _ =
  { tableState = AT.init columns data 5 }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    TableMsg tableMsg ->
      ( { model | tableState = AT.update tableMsg})

view : Model -> Html Msg
view model =
  div [] [ AT.view model.tableState TableMsg ]
```
