module Alpha

  P = 0
  N = 1
  B = 2
  R = 3
  Q = 4
  K = 5

  WHITE  =  0
  BLACK  =  1
  NULL   = -1
  EMPTY  =  6
  MAXPLY =  10
  INF    =  100_000_000

  R2_7   =  (8..55).freeze
  R3_6   =  (16..47).freeze
  R1_8   =  (0..63).freeze

  FLIP   =  [1, -1].freeze
  DIR    =  [-8, 8].freeze
  STEP   =  [-21, -19, -12, -8, 8, 12, 19, 21].freeze
  DIAG   =  [11, -11, -9, 9].freeze
  ORTH   =  [1, 10, -1, -10].freeze
  OCTL   =  [-9, 9, -11, 11, -10, 10, -1, 1].freeze
  STEPS  =  [DIR, STEP, DIAG, ORTH, OCTL, OCTL, DIR].freeze
  SLIDES =  [false, false, true, true, true, false, false].freeze
  VAL    =  [100, 320, 325, 540, 960, 0, 0].freeze
  SWAP   =  [[1, -1].freeze, [-1, 1].freeze].freeze

  SQ64 = [
    21, 22, 23, 24, 25, 26, 27, 28,
    31, 32, 33, 34, 35, 36, 37, 38,
    41, 42, 43, 44, 45, 46, 47, 48,
    51, 52, 53, 54, 55, 56, 57, 58,
    61, 62, 63, 64, 65, 66, 67, 68,
    71, 72, 73, 74, 75, 76, 77, 78,
    81, 82, 83, 84, 85, 86, 87, 88,
    91, 92, 93, 94, 95, 96, 97, 98
  ].freeze

  SQ120 = [
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1,  0,  1,  2,  3,  4,  5,  6,  7, -1,
    -1,  8,  9, 10, 11, 12, 13, 14, 15, -1,
    -1, 16, 17, 18, 19, 20, 21, 22, 23, -1,
    -1, 24, 25, 26, 27, 28, 29, 30, 31, -1,
    -1, 32, 33, 34, 35, 36, 37, 38, 39, -1,
    -1, 40, 41, 42, 43, 44, 45, 46, 47, -1,
    -1, 48, 49, 50, 51, 52, 53, 54, 55, -1,
    -1, 56, 57, 58, 59, 60, 61, 62, 63, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
  ].freeze

  POS = [ [
        0,  0,  0,  0,  0,  0,  0,  0,
       40, 70, 80, 90, 90, 80, 70, 40,
       10, 30, 40, 50, 50, 40, 30, 10,
        0,  5, 15, 15, 15, 15,  5,  0,
      -20, -5, 15, 30, 30, 15, -5,-20,
      -20,-10, 10, 10, 10, 10,-10,-20,
       25, 20, -5,-10,-10, -5, 20, 25,
        0,  0,  0,  0,  0,  0,  0,  0
    ].freeze, [
      -50,-40,-30,-30,-30,-30,-40,-50,
      -40,-20,  0,  0,  0,  0,-20,-40,
      -30,  0, 10, 15, 15, 10,  0,-30,
      -30,  5, 15, 20, 20, 15,  5,-30,
      -30,  0, 15, 20, 20, 15,  0,-30,
      -30,  5, 10, 15, 15, 10,  5,-30,
      -40,-20,  0,  5,  5,  0,-20,-40,
      -50,-40,-30,-30,-30,-30,-40,-50
    ].freeze, [
      -20,-10,-10,-10,-10,-10,-10,-20,
      -10,  0,  0,  0,  0,  0,  0,-10,
      -10,  0,  5, 10, 10,  5,  0,-10,
      -10,  5,  5, 15, 15,  5,  5,-10,
      -10,  0, 10, 15, 15, 10,  0,-10,
      -10, 10, 10, 10, 10, 10, 10,-10,
      -10,  5,  3,  5,  5,  3,  5,-10,
      -20,-10,-10,-10,-10,-10,-10,-20
    ].freeze, [
        0,  0,  0,  0,  0,  0,  0,  0,
        5, 10, 10, 10, 10, 10, 10,  5,
       -5,  0,  0,  0,  0,  0,  0, -5,
       -5,  0,  0,  0,  0,  0,  0, -5,
       -5,  0,  0,  0,  0,  0,  0, -5,
       -5,  0,  0,  0,  0,  0,  0, -5,
       -5,  0,  0,  0,  0,  0,  0, -5,
        0,  0,  0,  5,  5,  0,  0,  0
    ].freeze, [
      -20,-10,-10, -5, -5,-10,-10,-20,
      -10,  0,  0,  0,  0,  0,  0,-10,
      -10,  0,  5,  5,  5,  5,  0,-10,
       -5,  0,  5,  5,  5,  5,  0, -5,
        0,  0,  5,  5,  5,  5,  0, -5,
      -10,  5,  5,  5,  5,  5,  0,-10,
      -10,  0,  5,  0,  0,  0,  0,-10,
      -20,-10,-10, -5, -5,-10,-10,-20
    ].freeze, [
      -30,-40,-40,-50,-50,-40,-40,-30,
      -30,-40,-40,-50,-50,-40,-40,-30,
      -30,-40,-40,-50,-50,-40,-40,-30,
      -30,-40,-40,-50,-50,-40,-40,-30,
      -20,-30,-30,-40,-40,-30,-30,-20,
      -10,-20,-20,-20,-20,-20,-20,-10,
      -10,-10,-10,-10,-10,-10,-10,-10,
      -10,-10,-10,-10,-10,-10,-10,-10
    ].freeze
  ].freeze

  CENTER = [
    0, 0, 0, 1, 1, 0, 0, 0,
    0, 0, 1, 2, 2, 1, 0, 0,
    0, 1, 2, 3, 3, 2, 1, 0,
    1, 2, 4, 5, 5, 4, 2, 1,
    1, 2, 4, 5, 5, 4, 2, 1,
    0, 1, 2, 3, 3, 2, 1, 0,
    0, 0, 1, 2, 2, 1, 0, 0,
    0, 0, 0, 1, 1, 0, 0, 0
  ].freeze

  SQUARES = %w(
    a8 b8 c8 d8 e8 f8 g8 h8
    a7 b7 c7 d7 e7 f7 g7 h7
    a6 b6 c6 d6 e6 f6 g6 h6
    a5 b5 c5 d5 e5 f5 g5 h5
    a4 b4 c4 d4 e4 f4 g4 h4
    a3 b3 c3 d3 e3 f3 g3 h3
    a2 b2 c2 d2 e2 f2 g2 h2
    a1 b1 c1 d1 e1 f1 g1 h1
  ).freeze

  RANKS  = %w(1 2 3 4 5 6 7 8).freeze
  FILES  = %w(a b c d e f g h).freeze
  COLORS = %w(w b).freeze
  PIECES = [
    %w(P N B R Q K _).freeze,
    %w(p n b r q k _).freeze
  ].freeze
  PIECE_NAMES = %w(pawn knight bishop rook queen king).freeze
  COLOR_NAMES = %w(white black).freeze
  UNICODE = [
    %w(♙ ♘ ♗ ♖ ♕ ♔ _).freeze,
    %w(♟ ♞ ♝ ♜ ♛ ♚ _).freeze
  ].freeze

  FEN_REGEXP = /([rnbqkpRNBQKP1-8]+\/){7}([rnbqkpRNBQKP1-8]+)\s[bw]/.freeze
  FEN_INITIAL = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'.freeze
  FEN_KEY = {
    'P' => [0, 0],
    'N' => [0, 1],
    'B' => [0, 2],
    'R' => [0, 3],
    'Q' => [0, 4],
    'K' => [0, 5],
    'p' => [1, 0],
    'n' => [1, 1],
    'b' => [1, 2],
    'r' => [1, 3],
    'q' => [1, 4],
    'k' => [1, 5],
    '_' => [6, 6]
  }.freeze

end
