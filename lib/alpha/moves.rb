module Alpha

  Move = Struct.new(:from, :to, :piece, :target, :score) do

    include Comparable

    def <=>(other)
      other.score <=> score
    end

  end


  class Root

    include Comparable

    attr_accessor :score, :check, :move, :san, :fen, :mx, :surface_score


    def initialize(move, mx, check, fen, score)
      @move, @mx, @check, @fen = move, mx, check, fen
      @score = score
      @surface_score = score
      @san = generate_san
    end


    def <=>(other)
      other.score <=> score
    end


    def generate_san
      s = ''
      s += SQUARES[move.from][0] if move.piece == P && move.target != EMPTY
      s += PIECES[0][move.piece] unless move.piece == P
      s += 'x' unless move.target == EMPTY
      s += SQUARES[move.to]
      s += '=Q' if move.piece == P && !R2_7.cover?(move.to)
      s += '+' if check

      s
    end


    def to_s
      s =  "\033[96m#{san.rjust(5, ' ')}\033[0m #{UNICODE[mx][move.piece]}  #{SQUARES[move.from]}⇾#{SQUARES[move.to]}"
      s += " \033[95m#{UNICODE[mx ^ 1][move.target]}\033[0m" unless move.target == EMPTY
      s += ", \033[93mcheck\033[0m" if check

      s
    end


    def to_h
      {
        fen: fen,
        san: san,
        check: check,
        capture: move.target != EMPTY,
        score: score,
        color: COLOR_NAMES[mx],
        piece: PIECE_NAMES[move.piece],
        from: SQUARES[move.from],
        to: SQUARES[move.to],
        target: move.target == EMPTY ? 'empty' : PIECE_NAMES[move.target]
      }
    end

  end

end
