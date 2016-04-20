require_relative 'alpha/constants'
require_relative 'alpha/search'
require 'byebug'

module Alpha
  class << self
    
    # Parses a FEN position and returns a new Search that will start from it
    def load_position(fen = INIT_FEN)
      s, c = Array.new(120) { -1 }, Array.new(120) { -1 }
      fen.split[0].split('/').map do |row|
        row.chars.map { |sq| ('1'..'8').cover?(sq) ? ['6'] * sq.to_i : sq }
      end.flatten.each_with_index do |sq, i|
        s[SQ[i]] = %w(p n b r q k 6).index(sq.downcase)
        c[SQ[i]] = sq == '6' ? EMPTY : sq == sq.downcase ? BLACK : WHITE
      end
      Search.new(s, c, fen.split[1] == 'w' ? 0 : 1)
    end

    # Starts Search from a position, Search makes its move, we create a new Search from the position resulting from that move, and so on..
    def autoplay(duration = 4.0)
      s = load_position
      100.times do |i|
        s.find_move(duration)
        8.times.map do |j|
          puts SQ[(j*8), 8].map { |sq| s.squares[sq] == EMPTY ? '_'.center(3, ' ') : UTF8[s.colors[sq]][s.squares[sq]].center(3, ' ') }.join
        end
        m = s.root.move
        puts "#{PIECES[m.piece]} from #{PP[SQ64[m.from]]} to #{PP[SQ64[m.to]]}, rating: #{s.root.score}"
        puts "#{s.nodes} nodes @ #{(s.nodes / s.clock).round(2)}nps\n\n"
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
  
  # Root objects are each paired with a move that can be made from the current game position.  They keep track of
  # how successful the search is with its move in play, what the search was doing to yield good results, and the single
  # best move sequence originating from its move
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
