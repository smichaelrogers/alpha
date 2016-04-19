module Alpha
  class Search
    attr_reader :squares, :colors, :mx, :nodes, :clock, :best, :root
    
    def initialize(squares, colors, mx)
      @root = Root.new(Move.new, mx)
      @squares = squares
      @colors  = colors
      @mx, @mn = mx, mx ^ 1
      @kings = SQ.select { |sq| @squares[sq] == K }.sort_by { |sq| @colors[sq] }
      @moves, @on = Array.new(MAXPLY) { [] }, Array.new(MAXPLY)
      @ply, @_ply, @nodes = 0, 0, 0
    end
    
    def find_move(duration)
      roots = generate_moves.map { |m| Root.new(m.dup, @mx) }
      start_time, timed_out = Time.now, false
      2.upto(MAXPLY) do |i|
        @height = i
        roots.sort!.each do |r|
          @root = r
          next unless make(@root.move)
          @root.score = -alphabeta(-INF, INF, i)
          unmake(@root.move)
          timed_out = Time.now > start_time + duration
          break if timed_out
        end
        break if timed_out
      end
      @clock = Time.now - start_time
      @root = roots.first
      make(@root.move)
    end
    
    def alphabeta(alpha, beta, depth)
      @nodes += 1
      return evaluate if depth == 0 || @ply >= MAXPLY - 1
      @_ply, moved = @ply, false
      generate_moves.each do |m|
        next unless make(m)
        x = moved ? -alphabeta(-alpha-1, -alpha, depth - 1) :
                    -alphabeta(-beta, -alpha, depth - 1)
        moved = true
        unmake(m)
        if x > alpha
          @root.pt[m.piece][m.to] += ((depth+1)*@height) if m.target == EMPTY
          return beta if x >= beta
          @ply.upto(@_ply) { |i| @root.seq[i] = @on[i].dup if @on[i] }
          alpha = x
        end
      end
      alpha
    end
    
    def generate_moves
      @moves[@ply].clear.tap { |a| each_move { |i, j, k, l| a << Move.new(i, j, k, l).freeze } }.sort_by! do |m|
        m.target == EMPTY ? @root.seq[@ply] && @root.seq[@ply] == m ? 999_999 : @root.pt[m.piece][m.to] :
                            100_000 + m.target - m.piece
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
      @squares[m.to] == Q if m.piece == P && !(30..90).cover?(m.to)
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
        return true if @squares[k + STEP[i]] == N && @colors[k + STEP[i]] == @mn
        sq = k + OCTL[i]
        sq += OCTL[i] while @colors[sq] == EMPTY
        next unless @colors[sq] == @mn
        case @squares[sq]
        when Q; return true
        when B; return true if i < 4
        when R; return true if i > 3
        when P; return true if k + DIR[@mx] - 1 == sq || k + DIR[@mx] + 1 == sq
        when K; return true if sq - (k + OCTL[i]) == 0
        end
      end
      false
    end
    
    def swap!
      @mx, @mn = @mn, @mx
      true
    end

    def evaluate
      score = 0
      SQ.each do |i|
        score += 
            case @colors[i]
            when WHITE; VAL[@squares[i]] + POS[@squares[i]][SQ64[i]]
            when BLACK; -(VAL[@squares[i]] + POS[@squares[i]][SQ64[-i]])
            else next end 
      end
      score * FLIP[@mx]
    end
  end
  
end