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
* No CSS, and therefore no opinion on how it looks

## Half-Features (or Free Features?)

Some features are supported just due to the design of Elm applications. As the
signals sent by the table are piped into the table's `update` function by the
programmer using the table, additional features can be supplied to the table
without the table itself supporting them. Some examples:

* Updating the table data (it's in the table state as an `Array`)
* Remote sorting/filtering/pagination/etc., just return a `Cmd Msg` that can
  then dispatch a signal that will update the table

## Styling

I use [elm-css](https://package.elm-lang.org/packages/rtfeldman/elm-css/latest/).
The table itself has the class `autotable`, so that can be used to style
anything within the table. Learn your CSS selectors if you haven't already.
There are also two more class names in use:

* `span.autotable__sort-indicator` - The up/down arrow that displays the
  sorting direction for a column.
* `div.autotable__pagination` - Container for the pagination buttons.
* `button.autotable__pagination-page` - The pagination buttons themselves.
* `button.autotable__pagination-active` - The pagination button for the current
  page.

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

After that, you should just check out `Main.elm` to see how this library is
actually used in practice.
