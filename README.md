# Alpha

A very small chess engine written in Ruby

---

## Features
- ~150 lines of code
- Alpha Beta search algorithm

---

## PlayAlpha
I made a web app for playing against it:

Play it: 
[here](http://www.playalpha.xyz)

View source: 
[here](https://github.com/smichaelrogers/play-alpha)



## Usage

At the moment it just plays against itself for tuning purposes..

To try it out just clone this repo, and do something like this:

``` shell
$ irb
2.3.0 :001 > load 'lib/alpha.rb'
 => true 
2.3.0 :002 > Alpha.autoplay(duration: 16, loops: 9999)
  ♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜ 
  ♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟ 
  _ _ _ _ _ _ _ _ 
  _ _ _ _ _ _ _ _ 
  _ _ _ _ _ _ _ _ 
  _ _ _ _ ♙ _ _ _ 
  ♙ ♙ ♙ ♙ _ ♙ ♙ ♙ 
  ♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖ 
  517079 nodes @ 24275.67nps

  ♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜ 
  ♟ ♟ ♟ ♟ _ ♟ ♟ ♟ 
  _ _ _ _ ♟ _ _ _ 
  _ _ _ _ _ _ _ _ 
  _ _ _ _ _ _ _ _ 
  _ _ _ _ ♙ _ _ _ 
  ♙ ♙ ♙ ♙ _ ♙ ♙ ♙ 
  ♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖ 
  1342475 nodes @ 21592.63nps

  ♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜ 
  ♟ ♟ ♟ ♟ _ ♟ ♟ ♟ 
  _ _ _ _ ♟ _ _ _ 
  _ _ _ _ _ _ _ _ 
  _ _ _ _ _ _ _ _ 
  _ _ ♘ _ ♙ _ _ _ 
  ♙ ♙ ♙ ♙ _ ♙ ♙ ♙ 
  ♖ _ ♗ ♕ ♔ ♗ ♘ ♖ 
  2057103 nodes @ 20726.62nps

  ♜ _ ♝ ♛ ♚ ♝ ♞ ♜ 
  ♟ ♟ ♟ ♟ _ ♟ ♟ ♟ 
  _ _ ♞ _ ♟ _ _ _ 
  _ _ _ _ _ _ _ _ 
  _ _ _ _ _ _ _ _ 
  _ _ ♘ _ ♙ _ _ _ 
  ♙ ♙ ♙ ♙ _ ♙ ♙ ♙ 
  ♖ _ ♗ ♕ ♔ ♗ ♘ ♖ 
  2871139 nodes @ 21739.22nps

  ♜ _ ♝ ♛ ♚ ♝ ♞ ♜ 
  ♟ ♟ ♟ ♟ _ ♟ ♟ ♟ 
  _ _ ♞ _ ♟ _ _ _ 
  _ _ _ _ _ _ _ _ 
  _ _ _ _ _ _ _ _ 
  _ _ ♘ _ ♙ ♘ _ _ 
  ♙ ♙ ♙ ♙ _ ♙ ♙ ♙ 
  ♖ _ ♗ ♕ ♔ ♗ _ ♖ 
  370997 nodes @ 21266.57nps

  ♜ _ ♝ ♛ ♚ ♝ _ ♜ 
  ♟ ♟ ♟ ♟ _ ♟ ♟ ♟ 
  _ _ ♞ _ ♟ ♞ _ _ 
  _ _ _ _ _ _ _ _ 
  _ _ _ _ _ _ _ _ 
  _ _ ♘ _ ♙ ♘ _ _ 
  ♙ ♙ ♙ ♙ _ ♙ ♙ ♙ 
  ♖ _ ♗ ♕ ♔ ♗ _ ♖ 
  2712763 nodes @ 22102.45nps
```

---

## License
MIT