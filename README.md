![](logo.svg)

# Autotable

An in-development datatable for Elm. The code is not very good, but it should
work well for simple things. The code is going to be a bit bad for a while but
the functionality should work as advertised regardless. Strong types are great.

## Features

* Sorting
* Filtering
* Pagination
* Row selection
* Row editing
* Drag and drop reorderable columns

## Half-Features

Some features are supported just due to the design of Elm applications. As the
signals sent by the table are piped into the table's `update` function by the
programmer using the table, additional features can be supplied to the table
without the table itself supporting them. Some examples:

* Updating the table data (it's in the table state)
* Remote sorting/filtering/pagination/etc., just return a `Cmd Msg` that can then
  dispatch a signal that will update the table

## Todo

* Updating the table's data (with `AT.SetData` or something)
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
