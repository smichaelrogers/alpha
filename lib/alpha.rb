require_relative 'alpha/constants'
require_relative 'alpha/search'
require 'byebug'
require 'thread'

module Alpha  
  class << self
    
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
    
    def first_position
      from_fen(INITIAL_FEN)
    end
    
    def pp_nodes(n, c)
      "#{n} nodes @ #{(n / c).round(2)}/sec"
    end
    
    def pp_square(i)
      FILES[(i % 10) - 1] + RANKS[(i / 10) - 2]
    end
    
    def pp_root(r, m)
      "#{PIECES[m.piece]} from #{pp_square(m.from)} to #{pp_square(m.to)}#{m.target == EMPTY ? 
        '' : '('+PIECES[m.target]+')'} rating: #{r.score}"
    end
    
    def pp_board(s, c)
      8.times.map { |i| SQ[(i*8), 8].map { |sq| 
        s[sq] == EMPTY ? '_' : UTF8[c[sq]][s[sq]] 
      }.join(' ') }.join("\n")
    end
    
    def pp_search(s)
      [ pp_board(s.squares, s.colors),
        pp_root(s.best, s.best.move),
        pp_nodes(s.nodes, s.clock), 
        ("_" * 25), "\n"
      ].join("\n")
    end
    
    def autoplay(duration = 4.0)
      s = first_position
      turns = 0
      loop do
        turns += 1
        s.find_move(duration)
        puts "\n#{turns}\n#{pp_search(s)}"
        s = Search.new(s.squares, s.colors, s.mx)
      end
    end
  end
  
  Move = Struct.new(:from, :to, :piece, :target)
  
  class Root
    include Comparable
    
    attr_accessor :score, :pt, :seq
    attr_reader   :move, :color
    
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
