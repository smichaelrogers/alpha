module Alpha
  
  class Search
    attr_reader :roots, :root, :nodes, :clock, :nodes, :mn, :mx, :squares, :colors, :kings
    
    def initialize(squares, colors, kings, mx)
      @squares, @colors, @kings = squares, colors, kings
      @mx, @mn = mx, mx ^ 1
      @history = Array.new(MAXPLY) { Array.new(6) { Array.new(120) { 0 } } }
      @moves = Array.new(MAXPLY) { [] }
      @nodes, @height, @ply, @clock = 0, 1, 0, 0
      @root, @roots = nil, []
      generate_moves.each do |m|
        next unless make(m)
        @roots << m.dup
        unmake(m)
      end
    end
    
    def render
      8.times do |i|
        puts "  #{SQ[(i*8), 8].map { |j| UNICODE[@colors[j] % 6][@squares[j]] }.join(' ')} "
      end
      puts "  #{@nodes} nodes @ #{(@nodes / @clock).round(2)}nps\n\n"
    end
    
    def find_move(duration: 2.0)
      start = Time.now
      while Time.now < start + duration && @height < MAXPLY
        @height += 1
        @roots.each do |m|
          make(m)
          m.score = -alphabeta(-INF, INF, @height)
          unmake(m)
        end
        @root = @roots.sort!.first
      end
      @clock = Time.now - start
      @root
    end    

    def alphabeta(alpha, beta, depth)
      @nodes += 1
      return evaluate if depth == 0
      generate_moves.each do |m|
        next unless make(m)
        x = -alphabeta(-beta, -alpha, depth - 1)
        unmake(m)
        if x > alpha
          @history[@ply][m.piece][m.to] += (depth + 1) * @height if m.target == EMPTY
          return beta if x >= beta
          alpha = x
        end
      end
      alpha
    end

    def each_move(from)
      piece, color = @squares[from], @colors[from]
      if piece == P
        to = from + DIR[color]
        yield(to - 1, P, @squares[to - 1]) if @colors[to - 1] == color ^ 1
        yield(to + 1, P, @squares[to + 1]) if @colors[to + 1] == color ^ 1
        return unless @colors[to] == EMPTY
        yield(to, P, EMPTY)
        to += DIR[color]
        yield(to, P, EMPTY) if @squares[to] == EMPTY && !(40..80).cover?(from)
      else STEPS[piece].each do |step|
          to = from + step
          while @colors[to] == EMPTY
            yield(to, piece, EMPTY)
            break unless SLIDES[piece]
            to += step
          end
          yield(to, piece, @squares[to]) if @colors[to] == color ^ 1
        end
      end
    end
    
    def generate_moves
      @moves[@ply].clear.tap do |a|
        SQ.select { |sq| @colors[sq] == @mx }.each do |from| 
          each_move(from) do |to, piece, t| 
            a << Move.new(from, to, piece, t, t == EMPTY ? @history[@ply][piece][to] : 200_000 + t - piece).freeze
          end
        end
      end.sort!
    end
    
    def evaluate
      score = 0
      SQ.select { |sq| @colors[sq] != EMPTY }.each do |from|
        score += (VAL[@squares[from]] + POS[@squares[from]][FLIP[@colors[from]] * SQ64[from]]) * FLIP[@colors[from]]
        each_move(from) do |to, piece, t|
          score += (MOB[piece] + ATK[t] + (piece == P ? CENTER[SQ64[from]] : 0)) * FLIP[@colors[from]]
        end
      end
      score * FLIP[@mx]
    end

    def make(m)
      @ply += 1
      @squares[m.to], @colors[m.to] = m.piece, @mx
      @squares[m.from], @colors[m.from] = EMPTY, EMPTY
      @squares[m.to] = Q if m.piece == P && !(30..90).cover?(m.to)
      @kings[@mx] = m.to if m.piece == K
      @mx, @mn = @mn, @mx
      if in_check?(@mn)
        unmake(m)
        return false
      end
      true
    end
    
    def unmake(m)
      @ply -= 1
      @mx, @mn = @mn, @mx
      @colors[m.from], @squares[m.from] = @mx, m.piece
      @kings[@mx] = m.from if m.piece == K
      @colors[m.to], @squares[m.to] = EMPTY, m.target
      @colors[m.to] = @mn unless m.target == EMPTY
    end

    def in_check?(c)
      OCTL.each_with_index do |step, i|
        return true if @squares[@kings[c] + STEP[i]] == N && @colors[@kings[c] + STEP[i]] == c^1
        sq = @kings[c] + step
        sq += step until @colors[sq] != EMPTY
        next unless @colors[sq] == c ^ 1
        case @squares[sq]
        when Q then return true
        when B then return true if i < 4
        when R then return true if i > 3
        when P then return true if (@kings[c] + DIR[c] - sq).abs == 1
        when K then return true if @kings[c] + step == sq
        else next end
      end
      false
    end
    
  end
end