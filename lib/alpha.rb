require_relative 'alpha/constants'
require_relative 'alpha/search'
require 'byebug'

module Alpha
  
  def self.load_position(fen)
    squares, colors = Array.new(120) { NULL }, Array.new(120) { NULL }
    SQ.each { |i| squares[i], colors[i] = EMPTY, EMPTY }
    mx, mn = fen.split[1] == 'w' ? WHITE : BLACK, mx ^ 1
    fen.split.first.split('/').map do |row| 
      row.chars.map { |sq| ('1'..'8').cover?(sq) ? %w(e) * sq.to_i : sq }
    end.flatten.each_with_index { |sq, i| colors[SQ[i]], squares[SQ[i]] = FEN[sq][0], FEN[sq][1] }
    kings = SQ.select { |sq| squares[sq] == K }.sort_by { |sq| colors[sq] }
    Search.new(squares, colors, kings, mx)
  end
  
  
  def self.autoplay(duration: 2.0, fen: INIT_FEN, loops: 16)
    alpha = load_position(fen)
    loops.times do |i|
      if alpha.roots.empty?
        puts "#{CLR[alpha.mx]} lost"
        break
      end
      alpha.make(alpha.find_move(duration: duration))
      alpha.render
      alpha = Search.new(alpha.squares, alpha.colors, alpha.kings, alpha.mx)
    end
  end
  
end