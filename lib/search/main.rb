class Search
  attr_reader :squares, :colors, :mx, :nodes, :clock, :best

  def initialize(squares, colors, mx)
    @squares, @colors = squares, colors
    @mx, @mn = mx, mx ^ 1
    @kings = SQ.select { |sq| @squares[sq] == K }.sort_by { |sq| @colors[sq] }
    @moves = Array.new(MAXPLY)
    @history = Array.new(16) { Array.new(6) { Array.new(120) { 0 } } }
  end
  
  def find_move(duration = 4.0)
    @ply = 0
    @nodes = 0
    @roots = generate_moves.map { |m| { move: m.dup, score: -INF } }
    t = Time.now
    height = 1
    while Time.now < (t + duration) && height < MAXPLY
      height += 1
      @roots.sort_by! { |m| -m[:score] }
      @roots.each do |m|
        next unless make(m[:move])
        score = -alphabeta(-INF, INF, height)
        unmake(m[:move])
        m[:score] = score
        break if Time.now > (t + duration)
      end
    end
    @clock = Time.now - t
    @best = @roots.first
    make(@best[:move])
  end
    
  def alphabeta(alpha, beta, depth)
    return evaluate if depth == 0
    @nodes += 1
    generate_moves.each do |m|
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

  def evaluate
    score = 0
    SQ.select { |sq| @colors[sq] != EMPTY }.each { |from|
      score += ((MATERIAL[@squares[from]] + 
        POSITION[@squares[from]][SQ64[from * FLIP[@colors[from]]]]) * FLIP[@colors[from]]) }
    score *= -1 if @mx == BLACK
    score
  end

  def generate_moves
    mv = []
    SQ.select { |sq| @colors[sq] == @mx }.each do |from|
      piece = @squares[from]
      if piece == P
        to = from + DIR[@mx]
        mv << add_move(from, to + 1, P, @squares[to + 1]) if @colors[to + 1] == @mn
        mv << add_move(from, to - 1, P, @squares[to - 1]) if @colors[to - 1] == @mn
        next unless @colors[to] == EMPTY
        mv << add_move(from, to, P, EMPTY)
        if @squares[to + DIR[@mx]] == EMPTY && !(40..80).cover?(from)
          mv << add_move(from, to + DIR[@mx], P, EMPTY)
        end
      else STEPS[piece].each do |step|
          to = from + step
          while @colors[to] == EMPTY
            mv << add_move(from, to, piece, EMPTY)
            break unless SLIDING[piece]
            to += step
          end
          mv << add_move(from, to, piece, @squares[to]) if @colors[to] == @mn
          break
        end
      end
    end
    @moves[@ply] = mv.sort_by! { |m| -m.score }
  end
  
  def add_move(from, to, piece, target)
    m = Move.new(from, to, piece, target)
    m.score = target == EMPTY ? @history[@ply][piece][to] : (target + 1) * 9999
    m.freeze
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
  
  def swap!
    @mx, @mn = @mn, @mx
  end
end
