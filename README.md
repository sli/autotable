# autotable

An in-development datatable for Elm.

## Todo

* Row-level editing.
* Separate a column's sorting state from the data itself so sorting can be
  removed from a column. Sorts can currently be cleared but they clear to the
  Ascending direction.

## Usage

Can't, for the time being, since it's not published. But if you pull this code
to use it, don't forget you need a little Javascript. It can be found in
`static/index.html` but I'll put it here, too.

```js
document.body.addEventListener('dragstart', e =>
  e.dataTransfer.setData('text/plain', null))
```

After that, you should just check out `Main.elm` to see how this library is
actually used in practice.

## Row Editing / Filtering / Sorting Notes

I should probably rewrite the data to use an `Array` instead of a `List`, and
then rework the filtering / sorting functions to work directly on individual
rows / pairs of rows, respectively. That way the filtering, sorting, and row
modes can be controlled using the indexes without ever touching the data
itself.

Or, keep the data as a `List` and convert to `Array` when rendering to keep
`List` ergonomics? Tests will have to be done.

This does present a problem with data updating, though. Maybe an event that can
set new data? In the demo code, it might work something like:

```elm
TableMsg AT.UpdateData <| Array.append model.tableState.data someNewData
```

Or:

```elm
TableMsg AT.UpdateData <| model.tableState.data ++ someNewData
```
