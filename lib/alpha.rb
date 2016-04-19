require_relative 'alpha/constants'
require_relative 'alpha/search'

module Alpha  
  class << self
    def load_position(fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')
      s, c = Array.new(120) { -1 }, Array.new(120) { -1 }
      fen.split[0].split('/').map do |row|
        row.chars.map { |sq| ('1'..'8').cover?(sq) ? ['6'] * sq.to_i : sq }
      end.flatten.each_with_index do |sq, i|
        s[SQ[i]] = %w(p n b r q k 6).index(sq.downcase)
        c[SQ[i]] = sq == '6' ? EMPTY : sq == sq.downcase ? BLACK : WHITE
      end
      Search.new(s, c, fen.split[1] == 'w' ? 0 : 1)
    end
    
    def ppsq(i) FILES[(i % 10) - 1] + RANKS[(i / 10) - 2] end
    
    def print_board(s, c)
      8.times.map do |i| 
        puts SQ[(i*8), 8].map { |sq| s[sq] == EMPTY ? '_' : UTF8[c[sq]][s[sq]] }.join(' ')
      end
    end
    
    def print_data(r, m, n, c)
      puts "#{PIECES[m.piece]} from #{ppsq(m.from)} to #{ppsq(m.to)}, rating: #{r.score}"
      puts "#{n} nodes @ #{(n / c).round(2)}nps\n\n"
    end
    
    def autoplay(duration = 4.0)
      s = load_position
      100.times do |i|
        s.find_move(duration)
        print_board(s.squares, s.colors)
        print_data(s.root, s.root.move, s.nodes, s.clock)
        s = Search.new(s.squares, s.colors, s.mx)
      end
    end
  end
  
  Move = Struct.new(:from, :to, :piece, :target) do
    def ==(other)
      return false if !other
      from == other.from && to == other.to && target == other.target
    end
  end
  
  class Root
    include Comparable
    attr_accessor :score, :pt, :seq, :move, :color
    def initialize(move, color)
      @move = move
      @color = color
      @pt = Array.new(6) { Array.new(120) { 0 } }
      @seq = Array.new(MAXPLY)
      @score = -INF
    end
    
    def <=>(other)
      other.score <=> @score
    end
  end
end
