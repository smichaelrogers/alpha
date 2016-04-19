# alpha
Very small (~140 loc) chess engine, extracted/refactored from some other I made, auto promotes pawn to queen but doesn't manage castling/move repetition

at the moment it can just load FEN positions and play against itself:

```shell
$ irb
2.3.0 :001 > load 'lib/alpha.rb'
 => true 
2.3.0 :002 > Alpha.autoplay
♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟
_ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _
_ _ _ _ ♙ _ _ _
_ _ _ _ _ _ _ _
♙ ♙ ♙ ♙ _ ♙ ♙ ♙
♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖
P from e2 to e4, rating: 17
231076 nodes @ 55093.69nps

♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
♟ ♟ ♟ ♟ _ ♟ ♟ ♟
_ _ _ _ _ _ _ _
_ _ _ _ ♟ _ _ _
_ _ _ _ ♙ _ _ _
_ _ _ _ _ _ _ _
♙ ♙ ♙ ♙ _ ♙ ♙ ♙
♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖
P from e7 to e5, rating: 76
239405 nodes @ 58416.64nps

♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
♟ ♟ ♟ ♟ _ ♟ ♟ ♟
_ _ _ _ _ _ _ _
_ _ _ _ ♟ _ _ _
_ _ _ _ ♙ _ _ _
_ _ _ _ _ ♘ _ _
♙ ♙ ♙ ♙ _ ♙ ♙ ♙
♖ ♘ ♗ ♕ ♔ ♗ _ ♖
N from g1 to f3, rating: 122
244821 nodes @ 57097.61nps

♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
♟ ♟ ♟ ♟ _ _ ♟ ♟
_ _ _ _ _ _ _ _
_ _ _ _ ♟ ♟ _ _
_ _ _ _ ♙ _ _ _
_ _ _ _ _ ♘ _ _
♙ ♙ ♙ ♙ _ ♙ ♙ ♙
♖ ♘ ♗ ♕ ♔ ♗ _ ♖
P from f7 to f5, rating: 84
230895 nodes @ 56409.8nps

♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
♟ ♟ ♟ ♟ _ _ ♟ ♟
_ _ _ _ _ _ _ _
_ _ _ _ ♟ ♙ _ _
_ _ _ _ _ _ _ _
_ _ _ _ _ ♘ _ _
♙ ♙ ♙ ♙ _ ♙ ♙ ♙
♖ ♘ ♗ ♕ ♔ ♗ _ ♖
P from e4 to f5, rating: 218
243960 nodes @ 60201.91nps

♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
♟ ♟ ♟ ♟ _ _ ♟ ♟
_ _ _ _ _ _ _ _
_ _ _ _ _ ♙ _ _
_ _ _ _ ♟ _ _ _
_ _ _ _ _ ♘ _ _
♙ ♙ ♙ ♙ _ ♙ ♙ ♙
♖ ♘ ♗ ♕ ♔ ♗ _ ♖
P from e5 to e4, rating: -179
300158 nodes @ 61147.67nps

♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
♟ ♟ ♟ ♟ _ _ ♟ ♟
_ _ _ _ _ _ _ _
_ _ _ _ ♘ ♙ _ _
_ _ _ _ ♟ _ _ _
_ _ _ _ _ _ _ _
♙ ♙ ♙ ♙ _ ♙ ♙ ♙
♖ ♘ ♗ ♕ ♔ ♗ _ ♖
N from f3 to e5, rating: 211
256230 nodes @ 60511.24nps

♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
♟ ♟ ♟ _ _ _ ♟ ♟
_ _ _ _ _ _ _ _
_ _ _ ♟ ♘ ♙ _ _
_ _ _ _ ♟ _ _ _
_ _ _ _ _ _ _ _
♙ ♙ ♙ ♙ _ ♙ ♙ ♙
♖ ♘ ♗ ♕ ♔ ♗ _ ♖
P from d7 to d5, rating: -11
244360 nodes @ 60528.0nps

♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
♟ ♟ ♟ _ _ _ ♟ ♟
_ _ _ _ _ ♙ _ _
_ _ _ ♟ ♘ _ _ _
_ _ _ _ ♟ _ _ _
_ _ _ _ _ _ _ _
♙ ♙ ♙ ♙ _ ♙ ♙ ♙
♖ ♘ ♗ ♕ ♔ ♗ _ ♖
P from f5 to f6, rating: 236
256910 nodes @ 60589.94nps

♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
♟ ♟ ♟ _ _ _ _ ♟
_ _ _ _ _ ♟ _ _
_ _ _ ♟ ♘ _ _ _
_ _ _ _ ♟ _ _ _
_ _ _ _ _ _ _ _
♙ ♙ ♙ ♙ _ ♙ ♙ ♙
♖ ♘ ♗ ♕ ♔ ♗ _ ♖
P from g7 to f6, rating: 309
280854 nodes @ 60039.7nps

♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
♟ ♟ ♟ _ _ _ _ ♟
_ _ _ _ _ ♟ _ _
_ _ _ ♟ ♘ _ _ ♕
_ _ _ _ ♟ _ _ _
_ _ _ _ _ _ _ _
♙ ♙ ♙ ♙ _ ♙ ♙ ♙
♖ ♘ ♗ _ ♔ ♗ _ ♖
Q from d1 to h5, rating: 999999999
285313 nodes @ 60499.23nps

```
