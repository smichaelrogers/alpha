
# Alpha
A very small chess engine. Written in Ruby.


![alpha playing against itself](http://i.imgur.com/wmmGYUH.gif)


## Features
- Loads any position from FEN.
- Uses really simple alpha-beta pruning and move-history based heuristics.
- Evaluates ~50,000 nodes/second.
- Serializes attributes and search/game statistics into an object modeling a search instance.
- Written in about 150 lines of code.
- powers a web app called PlayAlpha [(repo)](https://github.com/smichaelrogers/play-alpha), [(live)](http://playalpha.xyz)

## Usage
clone repo,
cd into lib,

then to play..
```shell
load 'alpha.rb'
 => true

2.3.1 :002 > Alpha.play(duration: 4.0, human: true)

 white makes move   Nc3 ♘  b1⇾c3
 ──────────────────┬────────────────────────────────
 1 ♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜ │ Turn  2
 2 ♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟ │ SAN   Nc3
 3 _ _ _ _ _ _ _ _ │ Score -19(-65.6 avg.)
 4 _ _ _ _ _ _ _ _ │ Clock 9.93
 5 _ _ _ _ _ _ _ _ │ Nodes 573360
 6 _ _ ♘ _ _ _ _ _ │ NPS   57739.22
 7 ♙ ♙ ♙ ♙ ♙ ♙ ♙ ♙ │ NPH   20❯420❯1321❯15141❯63395❯493063
 8 ♖ _ ♗ ♕ ♔ ♗ ♘ ♖ │ NPP   120❯2000❯4731❯43870❯91089❯431550
   a b c d e f g h │ Eval  81

 Input move (ex. nf3 NF3 e4 etc.)

  Nc6 ♞  b8⇾c6          Nf6 ♞  g8⇾f6           e5 ♟  e7⇾e5       
   f5 ♟  f7⇾f5          Nh6 ♞  g8⇾h6           a6 ♟  a7⇾a6       
   d5 ♟  d7⇾d5           e6 ♟  e7⇾e6           g5 ♟  g7⇾g5       
   f6 ♟  f7⇾f6           d6 ♟  d7⇾d6           g6 ♟  g7⇾g6       
  Na6 ♞  b8⇾a6           a5 ♟  a7⇾a5           c5 ♟  c7⇾c5       
   h5 ♟  h7⇾h5           c6 ♟  c7⇾c6           h6 ♟  h7⇾h6       
   b5 ♟  b7⇾b5           b6 ♟  b7⇾b6       

  e5

  1 ♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
  2 ♟ ♟ ♟ ♟ _ ♟ ♟ ♟
  3 _ _ _ _ _ _ _ _
  4 _ _ _ _ ♟ _ _ _
  5 _ _ _ _ _ _ _ _
  6 _ _ ♘ _ _ _ _ _
  7 ♙ ♙ ♙ ♙ ♙ ♙ ♙ ♙
  8 ♖ _ ♗ ♕ ♔ ♗ ♘ ♖
    a b c d e f g h
```
or prettyprint the search object
```shell
Alpha.play(turns: 99999, duration: 4.0, human: true, pp: true)
{
          :turn => 2,
         :clock => 9.89,
         :nodes => 573360,
           :nps => 57968.22,
           :nph => [
        [0] 20,
        [1] 420,
        [2] 1321,
        [3] 15141,
        [4] 63395,
        [5] 493063
    ],
           :npp => [
        [0] 0,
        [1] 120,
        [2] 2000,
        [3] 4731,
        [4] 43870,
        [5] 91089,
        [6] 431550,
        [7] 0,
        [8] 0,
        [9] 0
    ],
    :evaluation => 81,
         :moves => [
        [ 0] {
                :san => "Nc3",
              :check => false,
            :capture => false,
              :score => -19,
              :color => "white",
              :piece => "knight",
               :from => "b1",
                 :to => "c3",
             :target => "empty"
```

## License
MIT
