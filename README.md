# ＡＳＣＩＩ　ＨＹＰＥＲＣＵＢＥ
Create word cubes and other [hyperrectangular] ASCII art.

[Try it out `ｏｎｌｉｎｅ` on this `ｗｅｂｐａｇｅ`｡](https://1j01.github.io/ascii-hypercube/)

[hyperrectangular]: https://en.wikipedia.org/wiki/Hyperrectangle

## Examples

### 1D

    N O T   V E R Y   I N T E R E S T I N G

If you want actual wide text, use [Vaporwave Text Generator](https://lingojam.com/VaporwaveTextGenerator).

### 2D

    S Q U A R E S    O N E → T W O    ONE→TWO
    Q           Q    N           N    N     N
    U   M E H   U    E           E    E     E
    A   E   E   A    ↓           ↓    ↓     ↓
    R   H E H   R    T           T    T     T
    E           E    W           W    W     W
    S Q U A R E S    O N E → T W O    ONE→TWO
    
    T Y P E S E T    T E X T    T Y P E S E T
    E           E    E     E    E           E
    S           S    S     S    X           X
    T Y P E S E T    T E X T    T Y P E S E T

### 3D

    H A H   Y E A H
    A\            A\
    H H A H   Y E A H
      A             A        C U B I C
    Y H           Y H      / U     / U
    E             E      C U B I C   B
    A Y           A Y    U   I   U   I
    H E H   Y E A H E    B   C U B I C
     \A            \A    I /     I /
      H A H   Y E A H    C U B I C

### 4D

    T E S S E R A C T
    E\ .            E\ .
    S \   .         S \   .
    S  \     .      S  \     .
    E   \       T E S S E R A C T
    R    T E S SE\ RRA C T      E\
    A    E  .   S \ A    E  .   S \
    C    S     .S  \C    S     .S  \
    T E SSS E R E C \    S      E . \
     \ . E      R    T E S S E RRA C T
      \  R.     A    E\  R.     A    E
       \ A   .  C    S \ A   .  C    S
        \C      T E SSS ECR A C T    S
         T E S S \ R E C T       \   E
            .     \  R      .     \  R
               .   \ A         .   \ A
                  . \C            . \C
                     T E S S E R A C T

### 5D

       R A T H E R   H Y P E R
      /A\ ~                 /A\ ~
     / T \   ~             / T \   ~
    R AHT H E R ~ H Y P E R  H  \     ~
    A\ ~   R A T H E R   HA\ ~ E R       ~
    T \R  ~A  ~       ~   T \R  ~A  ~       ~
    H  \ / T ~   ~       ~H  \ / T ~   ~       ~
    E  HR AHT H E R ~ H Y P EHR  H    ~   ~       ~
    R  YA  ~       ~   ~  R  YAR ~ T H E ~   H Y P E R
       PT  R  ~       ~   ~  PTA\R  ~       ~   ~   /A\
    H  EH        ~       ~H  EHT \     ~       ~   ~ T \
    Y  REA H H E R  ~H Y PYERRAHTHH E R   H Y P E R  H~ \
    P / R ~Y           ~  P A\RE~Y R A T H E ~   HA\ P E R
    E/   \ P ~            E/T \R P/A            ~ T \R  /A
    R A H HEE R ~ H Y P E R H~H\\E T  ~           H~ \ / T
     \ ~Y  R A T H E R   H \E~YHRRAHT H E~R   H Y P EHR  H
      \ P ~   ~       ~     R PYA  E~       ~     R  YA  E
       \E/   ~   ~       ~   \EPT  ~   ~       ~     PT  R
        R A T H E R ~ H Y P H REH     ~   ~       H  EH
           ~       ~   ~    Y  RE~ H H E ~   H Y PYE RE  H
              ~       ~   ~ P / R  Y~       ~   ~ P / R  Y
                 ~       ~  E~   \ P   ~       ~  E~   \ P
                    ~       R A H HEE R   H Y P E R   H \E
                       ~     \  Y  R A T H E ~   H \ PYE R
                          ~   \ P /             ~   \ P /
                             ~ \E/                 ~ \E/
                                R A T H E R   H Y P E R

## Library Usage

Install with npm:

```sh
npm install ascii-hypercube
```

Use in your code:
```js
const { renderHypercube } = require('ascii-hypercube')

const dimensions = [
  { length: 4, xPerGlyph: 2, yPerGlyph: 0, text: "CUBIC" },
  { length: 4, xPerGlyph: 0, yPerGlyph: 1, text: "CUBIC" },
  { length: 2, xPerGlyph: -2, yPerGlyph: 1, text: "/" },
];
const { text, numOverlaps, overlaps } = renderHypercube(dimensions);

console.log(text);
```

If you want to use the browser version, you can include the [script](https://unpkg.com/ascii-hypercube) in your HTML:

```html
<script src="ascii-hypercube.js"></script>
```

and it will define a global `renderHypercube` function.

## API

### `renderHypercube(dimensions: Dimension[], splitter?: GraphemeSplitter): { text: string, numOverlaps: number, overlaps: OverlapStats }`

- `dimensions` is an array of objects with the following properties:
  - `length` is the number of steps **between** the first and last glyph along the dimension. It should be one less than the number of glyphs to be plotted.
  - `xPerGlyph` is the number of characters to move right for each plotted glyph
  - `yPerGlyph` is the number of characters to move down for each plotted glyph
  - `text` is the text to render along edges of the dimension. It is repeated if `length` is greater than **or equal to** the length of the text.
  - `glyphs` is an alternative to `text` if you have already split the text into graphemes. Exactly one of `text` or `glyphs` should be provided.

- `splitter` is an optional [GraphemeSplitter](https://github.com/orling/grapheme-splitter) object with a `splitGraphemes` method.
  - When loaded in a browser, the library will try to use the global `GraphemeSplitter` if available.
  - In Node.js, `grapheme-splitter` is included as a dependency and will be used automatically.
  - If you want to use a different library or a custom implementation, you can pass it in here.

- Returns an object with the following properties:
  - `text` is the rendered hypercube as a string
  - `numOverlaps` is the number of times a glyph was plotted that didn't match the glyph that was already there
  - `overlaps` is an object that gives statistics about the overlaps.
    - Each key is a glyph that was overwritten, and each value is an object with keys being overriding glyphs and values being the number of times that overlap occurred.

## CLI

You can also use the command-line interface. If you have Node.js installed, you can simply use `npx` to run it:

```sh
npx ascii-hypercube -d 2,0 3 'TEST' -d 0,1 3 'TEXT' -d -1,1 4 '///'
```

To install as a global command:

```sh
npm install -g ascii-hypercube
```

Then you can run it without `npx`.

```HELP_OUTPUT
usage: ascii-hypercube [-h] [-d TRAVEL LENGTH TEXT] [-s]

CLI to render hypercubes with text along an arbitrary number of dimensions

optional arguments:
  -h, --help            show this help message and exit
  -d TRAVEL LENGTH TEXT, --dimension TRAVEL LENGTH TEXT
                        Define a dimension, with travel per glyph, length of
                        edges along the dimension, and text. Can be specified
                        multiple times. Travel must be given as a pair of
                        numbers with no spaces, e.g. "-1,0" or "(-1,0)"
  -s, --stats           Print statistics about the overlaps

Example: ascii-hypercube -d 2,0 11 'RATHER HYPER' -d 0,1 11 'RATHER HYPER' -d
1,1 4 '\\' -d 3,1 8 '\~' -d -1,1 3 '\/'
```

## Development

This project is written in CoffeeScript.

### Library

Add tests to [`src/test.js`](src/test.js) and run them with:
```sh
npm test
```

### Web App

Any static file server will do. One that auto-reloads is nice:
```sh
npx live-server .
```

### CLI

Update help in this readme with:
```sh
npm run update-cli-docs
```

## License

MIT-licensed; see [LICENSE](LICENSE) for details

