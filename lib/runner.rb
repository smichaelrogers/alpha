module Alpha
  class Runner
    class << self
      def notation_for_square(i)
        RANKS[10 - (i / 8)] + FILES[(i % 10) - 1]
      end
      
      def first_position
        from_fen(INITIAL_FEN)
      end
      
      def from_fen(fen)
        squares = Array.new(120) { -1 }
        colors  = Array.new(120) { -1 }
        mx = fen.split[1] == 'w' ? 0 : 1
        fen.split[0].split('/').map do |row|
          row.chars.map { |sq| ('1'..'8').cover?(sq) ? ['6'] * sq.to_i : sq }
        end.flatten.each_with_index do |sq, i|
          squares[SQ[i]] = %w(p n b r q k 6).index(sq.downcase)
          colors[SQ[i]] = sq == '6' ? EMPTY : sq == sq.downcase ? BLACK : WHITE
        end

        Search.new(squares, colors, mx)
      end
      
      def autoplay
        s = first_position
        loop do
          s.find_move
          puts [("_" * 32), s.render_board, s.best.to_h].join("\n\n")
          colors = s.colors
          squares = s.squares
          mx = s.mx
          s = Search.new(squares, colors, mx)
        end
      end
    end
  end
end
