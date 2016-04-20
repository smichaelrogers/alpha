module Alpha
  class Search
    attr_reader :squares, :colors, :mx, :nodes, :clock, :best, :root    
    
    # Stores the passed in position at ply zero
    def initialize(squares, colors, mx)
      @root = Root.new(Move.new, mx)
      @squares = squares
      @colors  = colors
      @mx, @mn = mx, mx ^ 1
      @kings = SQ.select { |sq| @squares[sq] == K }.sort_by { |sq| @colors[sq] }
      @moves = Array.new(MAXPLY) { [] }
      @ply, @_ply, @nodes = 0, 0, 0
    end
    
    # Iterates through the roots of the move tree, selects a move and advances to the position resulting from it
    def find_move(duration)
      roots = generate_moves.map { |m| Root.new(m.dup, @mx) }
      start_time = Time.now
      timed_out = false
      height = 3
      while height < MAXPLY && !timed_out
        height += 1
        roots.each do |r|
          @root = r
          next unless make(@root.move)
          @on = Array.new(MAXPLY)
          @root.score = -alphabeta(-INF, INF, height)
          unmake(@root.move)
          timed_out = Time.now > start_time + duration
          break if timed_out
        end
        roots.sort!
      end
      puts height
      @clock = Time.now - start_time
      @root = roots.first
      make(@root.move)
    end
    
    # Follows an arrangement of moves until the depth reaches zero, returning an evaluation of the resulting node
    def alphabeta(alpha, beta, depth)
      @nodes += 1
      return evaluate if depth == 0 || @ply >= MAXPLY - 1
      @_ply = @ply
      generate_moves.each do |m|
        next unless make(m)
        if m.target == K
          debugger
        end
        x = -alphabeta(-beta, -alpha, depth - 1)
        unmake(m)
        if x > alpha
          @root.pt[m.piece][m.to] += depth if m.target == EMPTY
          return beta if x >= beta
          @ply.upto(@_ply) { |i| @root.seq[i] = @on[i].dup if @on[i] }
          alpha = x
        end
      end
      alpha
    end
    
    # Creates an enumerator for all pseudolegal movement vectors
    def each_move
      SQ.select { |sq| @colors[sq] == @mx }.each do |from|
        if @squares[from] == P
          to = from + DIR[@mx]
          [to + 1, to - 1].each { |n| yield(from, n, P, @squares[n]) if @colors[n] == @mn }
          next unless @colors[to] == EMPTY
          yield(from, to, P, EMPTY)
          to += DIR[@mx]
          yield(from, to, P, EMPTY) if @squares[to] == EMPTY && !INNER_SQ.cover?(from)
        else STEPS[@squares[from]].each do |step|
            to = from + step
            while @colors[to] == EMPTY
              yield(from, to, @squares[from], EMPTY)
              break unless SLIDING[@squares[from]]
              to += step
            end
            yield(from, to, @squares[from], @squares[to]) if @colors[to] == @mn
            break
          end
        end
      end
    end
    
    # Creates and sorts Moves from the vectors found in each_move()
    def generate_moves
      @moves[@ply].clear.tap { |a| each_move { |i, j, k, l| a << Move.new(i, j, k, l).freeze } }.sort_by! do |m|
        if m.target == EMPTY
          @root.seq[@ply] && @root.seq[@ply] == m ? 800_000 : @root.pt[m.piece][m.to]
        else
          200_000 + m.target - m.piece
        end
      end
    end

    # Moves a piece.  Keeps track of king positions to speed up in_check?().  Handles pawn promotions
    def make(m)
      @on[@ply] = m
      @squares[m.from], @colors[m.from] = EMPTY, EMPTY
      @squares[m.to], @colors[m.to] = m.piece, @mx
      @kings[@mx] == m.to if m.piece == K
      @squares[m.to] == Q if m.piece == P && !(30..90).cover?(m.to)
      @ply += 1
      if in_check?
        swap! && unmake(m)
        return false
      end
      swap!
    end
    
    def unmake(m)
      swap!
      @ply -= 1
      @squares[m.from], @colors[m.from] = m.piece, @mx
      @squares[m.to], @colors[m.to] = m.target, m.target == EMPTY ? EMPTY : @mn
      @kings[@mx] = m.from if m.piece == K
    end    
    
    # Follows every legal path of movement from the kings position outward.  Returns true once an attacker is found
    def in_check?
      k = @kings[@mx]
      8.times do |i|
        return true if @squares[k + STEP[i]] == N && @colors[k + STEP[i]] == @mn
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

    # Returns an assessment of the current node relative to the maximizing player. 
    def evaluate
      score = 0
      SQ.select { |i| @colors[i] != EMPTY }.each do |i|
        score += @colors[i] == WHITE ? VAL[@squares[i]] + POS[@squares[i]][SQ64[i]] :  -(VAL[@squares[i]] + POS[@squares[i]][SQ64[-i]])
      end
      score * FLIP[@mx]
    end
    
    def swap!
      @mx, @mn = @mn, @mx
      true
    end
  end
end