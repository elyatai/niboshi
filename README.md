# Niboshi

Niboshi is an open-source experimental block-placing game based on
customizable generalized polyominoes. It was created to experiment with the
playability of non-Von Neumann neighborhoods in terms of piece generation,
and supports O(hⁿ o)* generation from an arbitrary neighborhood of adjacent
tiles.

\* where o=1, h = neighborhood cardinality, n = tiles per piece

## Etymology

Niboshi is Japanese dried sardines. I don't remember why I chose that name
for this project.

## Running

```sh
love ./src
```

## Known issues

- rotating sometimes leaves the piece in a wall
- sonic drop sometimes goes upwards
- key bindings are not customizable in-game
- adjacency neighborhoods are hardcoded
- russian translations have not been reviewed by a native

## Credits

The game runs on the [LÖVE](https://love2d.org/) game engine.

### Inspiration

The design for the project was mostly inspired by
[ry00001/plumino2](https://github.com/plumino/plumino2)

### Fonts

All licenses included under src/assets/fonts/licenses.

- [Fugaz One](https://fonts.google.com/specimen/Fugaz+One)
- [Noto Sans](https://fonts.google.com/specimen/Noto+Sans)
- [Roboto Mono](https://fonts.google.com/specimen/Roboto+Mono)
- [Togalité](https://moji-waku.com/togalite/index.html)
- [Yeseva One](https://fonts.google.com/specimen/Yeseva+One)

### Translations

- some strings taken from [Jstris](https://jstris.jezevec10.com/)

### Libraries

- [rxi/json.lua](https://github.com/rxi/json.lua)
