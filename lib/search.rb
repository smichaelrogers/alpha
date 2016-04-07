require_relative 'constants'
require_relative 'runner'

module Alpha
  class Search
    attr_reader :squares, :colors, :mx, :nodes, :clock, :best
    
    def initialize(squares, colors, mx)
      @squares = squares
      @colors  = colors
      @mx, @mn = mx, mx ^ 1 
      @kings = SQ.select { |sq| @squares[sq] == K }.sort_by { |sq| @colors[sq] }
      @nodes = Array.new(MAXPLY) { 0 }
      @history = Array.new(16) { Array.new(6) { Array.new(120) { 0 } } }
      @ply = 0
    end
    
    def find_move(duration = 8.0)
      roots = []
      generate_moves { |m| roots << { move: m.dup, score: -INF } }
      start_time = Time.now
      timed_out = false
      
      4.upto(MAXPLY) do |i|
        roots.sort_by! { |m| -m[:score] }.each do |m|
          next unless make(m[:move])
          
          score = -alphabeta(-INF, INF, i)
          unmake(m[:move])
          m[:score] = score
          timed_out = Time.now > start_time + duration
          break if timed_out
        end
        break if timed_out
      end
      @clock = Time.now - start_time
      @best = roots.first
      make(@best[:move])
    end
    
    def alphabeta(alpha, beta, depth)
      return evaluate if depth == 0
      
      @nodes[@ply] += 1
      generate_moves do |m|
        next unless make(m)
        score = -alphabeta(-beta, -alpha, depth - 1)
        unmake(m)
        
        if score > alpha
          @history[@ply][m.piece][m.to] += depth
          return beta if score >= beta
          alpha = score
        end
      end
      alpha
    end
    
    def generate_moves
      quiet = []
      
      SQ.select { |sq| @colors[sq] == @mx }.each do |from|
        piece = @squares[from]
        
        if piece == P
          to = from + DIR[@mx]
          yield(Move.new(from, to + 1, P, @squares[to + 1]).freeze) if @colors[to + 1] == @mn
          yield(Move.new(from, to - 1, P, @squares[to - 1]).freeze) if @colors[to - 1] == @mn
          next unless @colors[to] == EMPTY
          quiet << Move.new(from, to, P, EMPTY).freeze
          quiet << Move.new(from, to + DIR[@mx], P, EMPTY).freeze if 
            @squares[to + DIR[@mx]] == EMPTY && !(40..80).cover?(from)
            
        else STEPS[piece].each do |step|
            to = from + step
            while @colors[to] == EMPTY
              quiet << Move.new(from, to, piece, EMPTY).freeze
              break unless SLIDING[piece]
              to += step
            end
            yield(Move.new(from, to, piece, @squares[to]).freeze) if @colors[to] == @mn
            break
          end
        end
      end
      quiet.sort_by! { |m| -@history[@ply][m.piece][m.to] }.each { |m| yield(m) }
    end

    def make(m)
      @on_move[@ply] = m
      @squares[m.from], @colors[m.from] = EMPTY, EMPTY
      @squares[m.to], @colors[m.to] = m.piece, @mx
      @ply += 1
      @kings[@mx] == m.to if m.piece == K
      if in_check?
        swap!
        unmake(m)
        return false
      end
      swap!
      true
    end
    
    def unmake(m)
      swap!
      @ply -= 1
      @squares[m.from], @colors[m.from] = m.piece, @mx
      @squares[m.to], @colors[m.to] = m.target, m.target == EMPTY ? EMPTY : @mn
      @kings[@mx] = m.from if m.piece == K
    end    
    
    def in_check?
      k = @kings[@mx]
      8.times do |i|
        sq = k + STEP[i]
        return true if @squares[sq] == N && @colors[sq] == @mn
        sq = k + OCTL[i]
        sq += OCTL[i] while @colors[sq] == EMPTY
        next unless @colors[sq] == @mn
        case @squares[sq]
        when Q then return true
        when B then return true if i < 4
        when R then return true if i > 3
        when P then return true if k + DIR[@mx] - 1 == sq || k + DIR[@mx] + 1 == sq
        when K then return true if sq - (k + OCTL[i]) == 0
        end
      end
      false
    end
    
    def swap!; @mx, @mn = @mn, @mx end
    
    def all_pieces
      SQ.select { |sq| @colors[sq] != EMPTY }.each do |from|
        yield(@squares[from], @colors[from], from)
      end
    end

    def evaluate
      score = 0
      all_pieces { |piece, color, from| score += eval_for(piece, color, from) }
      @mx == BLACK ? (score * -1) : score
    end
    
    def eval_for(piece, color, from)
      color == WHITE ? MATERIAL[piece] + POSITION[piece][SQ64[from]] :
                     -(MATERIAL[piece] + POSITION[piece][-SQ64[from]])
    end
    
    def render_board
      8.times.map { |i| SQ[(i*8), 8].map { |sq| 
        @squares[sq] == EMPTY ? '_' : UTF8[@colors[sq]][@squares[sq]] 
      }.join(' ') }.join("\n")
    end
  end
end