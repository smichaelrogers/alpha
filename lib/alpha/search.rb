module Alpha
  class Search
    
    attr_reader :squares, :colors, :mx, :nodes, :clock, :best
    
    def initialize(squares, colors, mx)
      @root = Root.new(Move.new, mx)
      @squares = squares
      @colors  = colors
      @mx, @mn = mx, mx ^ 1
      @kings = SQ.select { |sq| @squares[sq] == K }.sort_by { |sq| @colors[sq] }
      @moves = Array.new(MAXPLY) { [] }
      @on = Array.new(MAXPLY)
      @_ply, @ply, @nodes = 0, 0, 0
    end
    
    def find_move(duration)
      roots = []
      generate_moves
      @moves[@ply].each { |m| roots << Root.new(m.dup, @mx) }
      start_time = Time.now
      timed_out = false
      2.upto(MAXPLY) do |i|
        @height = i
        roots.sort!.each do |r|
          next unless make(r.move)
          @root = r
          @root.score = -alphabeta(-INF, INF, i)
          unmake(@root.move)
          timed_out = Time.now > start_time + duration
          break if timed_out
        end
        break if timed_out
      end
      @clock = Time.now - start_time
      @best = roots.first
      make(@best.move)
    end
    
    def alphabeta(alpha, beta, depth)
      return evaluate if depth == 0
      moved = false
      @nodes += 1
      @_ply = @ply
      generate_moves
      @moves[@ply].each do |m|
        next unless make(m)
        x = moved ? -alphabeta(-beta, -alpha, depth - 1) : 
                    -alphabeta(-alpha-1, -alpha, depth - 1)
        moved = true
        unmake(m)
        if x > alpha
          @root.pt[m.piece][m.to] += ((depth+1)*@height) if m.target == EMPTY
          return beta if x >= beta
          alpha = x
          @ply.upto(@_ply) { |i| @root.seq[i] = @on[i].dup if @on[i] }
        end
      end
      moved ? alpha : in_check? ? -INF : 0
    end
    
    def generate_moves
      @moves[@ply].clear.tap do |a| 
        each_move { |i, j, k, l| a << Move.new(i, j, k, l).freeze }
      end.tap do |a|
        a.sort_by! { |m| ((m == @root.seq[@ply] ? 100_000 : 0) +
          m.target == EMPTY ? @root.pt[m.piece][m.to] : 10_000 + m.target - m.piece) } 
      end
    end
    
    def each_move
      SQ.select { |sq| @colors[sq] == @mx }.each do |from|
        piece = @squares[from]
        if piece == P
          to = from + DIR[@mx]
          yield(from, to + 1, P, @squares[to + 1]) if @colors[to + 1] == @mn
          yield(from, to - 1, P, @squares[to - 1]) if @colors[to - 1] == @mn
          next unless @colors[to] == EMPTY
          yield(from, to, P, EMPTY)
          yield(from, to + DIR[@mx], P, EMPTY) if @squares[to + DIR[@mx]] == EMPTY && !(40..80).cover?(from)
        else STEPS[piece].each do |step|
            to = from + step
            while @colors[to] == EMPTY
              yield(from, to, piece, EMPTY)
              break unless SLIDING[piece]
              to += step
            end
            yield(from, to, piece, @squares[to]) if @colors[to] == @mn
            break
          end
        end
      end
    end

    def make(m)
      @on[@ply] = m
      @squares[m.from], @colors[m.from] = EMPTY, EMPTY
      @squares[m.to], @colors[m.to] = m.piece, @mx
      @ply += 1
      @kings[@mx] == m.to if m.piece == K
      if in_check?
        swap! && unmake(m)
        return false
      end
      swap!
    end
    
    def unmake(m)
      swap! && @ply -= 1
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
    
    def swap!
      @mx, @mn = @mn, @mx
      true
    end

    def evaluate
      x = 0
      SQ.select { |sq| @colors[sq] != EMPTY }.each do |i|
        x += ((VAL[@squares[i]] + POS[@squares[i]][SQ64[i * FLIP[@colors[i]]]]) * FLIP[@colors[i]])
      end
      @mx == WHITE ? x : -x
    end
  end
end