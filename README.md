# autotable

An in-development datatable for Elm. The code is not very good, but it should
work well for simple things.

## Todo

* Decouple filter/sorting/editing from data.
* Row-level editing.

## Running Demo

`$ yarn install && yarn start`

## Usage

Can't, for the time being, since it's not published. But if you pull this code
to use it, don't forget you'll need a little Javascript. It can be found in
`static/index.html`, but I'll put it here, too.

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

The way to implement this seems like generating the indexes, and having generic
filter/sort functions that map between indexes and elements in the dataset to
apply the user-specified `sortFn`.

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
