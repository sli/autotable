![][logo.svg]

An in-development datatable for Elm. The code is not very good, but it should
work well for simple things.

## Todo

* Row-level editing. The mode can be entered but no signals are sent.

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
