![](logo.svg)

An in-development datatable for Elm. The code is not very good, but it should
work well for simple things. The code is going to be a bit bad for a while but
the functionality should work as advertised regardless. Strong types are great.

## Todo

* Updating the table's data (with `AT.SetData` or something)
* Resizable columns
* ~~Row selection~~
* Select All functionality
* Documentation, even if usage is a bit awkward

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
