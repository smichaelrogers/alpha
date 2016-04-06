require_relative 'search/constants'
require_relative 'search/main'

class Search
  class << self    
    def autoplay
      s = first_position
      loop do
        s.find_move
        puts [
          ("_" * 32),
          s.render_board,
          "#{UTF8[s.mx^1][s.best[:move].piece]} #{SQ_ID[s.best[:move].from]}->#{SQ_ID[s.best[:move].to]} (#{s.nodes} nodes @ #{(s.nodes / s.clock).round(2)} nps)",
        ].join("\n\n")
        colors = s.colors
        squares = s.squares
        mx = s.mx
        s = Search.new(squares, colors, mx)
      end
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

      new(squares, colors, mx)
    end
  end
  
  def render_board
    8.times.map { |i|
      SQ[(i*8), 8].map { |sq|
        @squares[sq] == EMPTY ? '_' : UTF8[@colors[sq]][@squares[sq]]
      }.join(' ')
    }.join("\n")
  end
end
