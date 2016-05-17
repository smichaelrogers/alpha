module Alpha
  
  Move = Struct.new(:from, :to, :piece, :target, :score) do
    include Comparable
    def <=>(other)
      other.score <=> score
    end
  end
  
  P = 0
  N = 1
  B = 2
  R = 3
  Q = 4
  K = 5
  
  NULL = -1
  EMPTY = 6
  WHITE = 0
  BLACK = 1
  MAXPLY = 8
  INF    = 999_999
  
  FLIP   = [1, -1].freeze
  DIR    = [-10, 10].freeze
  STEP   = [-21, -19, -12, -8, 8, 12, 19, 21].freeze
  DIAG   = [11, -11, -9, 9].freeze
  ORTH   = [1, 10, -1, -10].freeze
  OCTL   = [-9, 9, -11, 11, -10, 10, -1, 1].freeze
  STEPS  = [DIR, STEP, DIAG, ORTH, OCTL, OCTL, DIR].freeze
  SLIDES = [false, false, true, true, true, false, false].freeze
  
  FEN = { 'P' => [0, 0], 'N' => [0, 1], 'B' => [0, 2], 'R' => [0, 3], 'Q' => [0, 4], 'K' => [0, 5],
          'p' => [1, 0], 'n' => [1, 1], 'b' => [1, 2], 'r' => [1, 3], 'q' => [1, 4], 'k' => [1, 5],
          'e' => [6, 6] }.freeze
          
  FILES = %w(a b c d e f g h).freeze
  RANKS = %w(1 2 3 4 5 6 7 8).freeze
  PIECES = [%w(P N B R Q K e).freeze, %w(p n b r q k e).freeze].freeze
  COLORS = %w(w b).freeze
  CLR = %w(white black _ _ _ _ empty).freeze
  PCS = %w(pawn knight bishop rook queen king empty).freeze
  UNICODE = [%w(♙ ♘ ♗ ♖ ♕ ♔ _).freeze, %w(♟ ♞ ♝ ♜ ♛ ♚ _).freeze].freeze
  INIT_FEN = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w'.freeze
  
  SQ = [21, 22, 23, 24, 25, 26, 27, 28,
        31, 32, 33, 34, 35, 36, 37, 38,
        41, 42, 43, 44, 45, 46, 47, 48,
        51, 52, 53, 54, 55, 56, 57, 58,
        61, 62, 63, 64, 65, 66, 67, 68,
        71, 72, 73, 74, 75, 76, 77, 78,
        81, 82, 83, 84, 85, 86, 87, 88,
        91, 92, 93, 94, 95, 96, 97, 98].freeze
        
  PP   = SQ.map { |i| FILES[(i % 10) - 1] + RANKS[9 - (i / 10)] }
  SQ64 = Array.new(120) { -1 }.tap { |a| 64.times { |i| a[SQ[i]] = i } }.freeze
  VAL  = [100, 320, 330, 500, 900, 0, 0].freeze
  MOB  = [1, 3, 2, 2, 1, 0, 0].freeze
  ATK  = [1, 3, 3, 5, 9, 11, 0].freeze
  POS  = [[0,  0,  0,  0,  0,  0,  0,  0, 50, 50, 50, 50, 50, 50, 50, 50, 10, 10, 20, 30, 30, 20, 10, 10, 5,  5, 10, 25, 25, 10,  5,  5, 0,  0,  0, 20, 20,  0,  0,  0, 5, -5,-10,  0,  0,-10, -5,  5, 5, 10, 10,-20,-20, 10, 10,  5, 0,  0,  0,  0,  0,  0,  0,  0].freeze, 
          [-50,-40,-30,-30,-30,-30,-40,-50, -40,-20,  0,  0,  0,  0,-20,-40, -30,  0, 10, 15, 15, 10,  0,-30, -30,  5, 15, 20, 20, 15,  5,-30, -30,  0, 15, 20, 20, 15,  0,-30, -30,  5, 10, 15, 15, 10,  5,-30, -40,-20,  0,  5,  5,  0,-20,-40, -50,-40,-30,-30,-30,-30,-40,-50].freeze, 
          [-20,-10,-10,-10,-10,-10,-10,-20, -10,  0,  0,  0,  0,  0,  0,-10, -10,  0,  5, 10, 10,  5,  0,-10, -10,  5,  5, 10, 10,  5,  5,-10, -10,  0, 10, 10, 10, 10,  0,-10, -10, 10, 10, 10, 10, 10, 10,-10, -10,  5,  0,  0,  0,  0,  5,-10, -20,-10,-10,-10,-10,-10,-10,-20].freeze, 
          [ 0,  0,  0,  0,  0,  0,  0,  0, 5, 10, 10, 10, 10, 10, 10,  5, -5,  0,  0,  0,  0,  0,  0, -5, -5,  0,  0,  0,  0,  0,  0, -5, -5,  0,  0,  0,  0,  0,  0, -5, -5,  0,  0,  0,  0,  0,  0, -5, -5,  0,  0,  0,  0,  0,  0, -5, 0,  0,  0,  5,  5,  0,  0,  0].freeze, 
          [-20,-10,-10, -5, -5,-10,-10,-20, -10,  0,  0,  0,  0,  0,  0,-10, -10,  0,  5,  5,  5,  5,  0,-10, -5,  0,  5,  5,  5,  5,  0, -5, 0,  0,  5,  5,  5,  5,  0, -5, -10,  5,  5,  5,  5,  5,  0,-10, -10,  0,  5,  0,  0,  0,  0,-10, -20,-10,-10, -5, -5,-10,-10,-20].freeze, 
          [-30,-40,-40,-50,-50,-40,-40,-30,-30,-40,-40,-50,-50,-40,-40,-30,-30,-40,-40,-50,-50,-40,-40,-30,-30,-40,-40,-50,-50,-40,-40,-30,-20,-30,-30,-40,-40,-30,-30,-20,-10,-20,-20,-20,-20,-20,-20,-10,-10,-10,-10,-10,-10,-10,-10,-10,-10,-10,-10,-10,-10,-10,-10,-10].freeze].freeze
  CENTER = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 2, 1, 0, 0, 0, 1, 3, 4, 4, 3, 1, 0, 0, 1, 3, 4, 4, 3, 1, 0, 0, 0, 1, 2, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0].freeze
end