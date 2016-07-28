module Alpha
  class Engine

    attr_accessor :duration, :fen, :turn, :data, :root, :roots

    def reset!
      @ply = @clock = @height = @nodes = @evaluation = 0
      @history = Array.new(MAXPLY) { Array.new(6) { Array.new(64) { 0 } } }
      @moves = Array.new(MAXPLY) { [] }
      @npp = Array.new(MAXPLY) { 0 }
      @nph, @roots = [], []
      @mn = @mx ^ 1
      @ev_i = evaluate(@mx)

      generate_moves.each do |m|
        next unless make(m)
        @roots << Root.new(m.dup, @mn, in_check?(@mx), render_fen, evaluate(@mn) - @ev_i)
        unmake(m)
      end

      @root = @roots.sort!.first
    end

    #
    def search
      start_time = Time.now

      while @height + 1 < MAXPLY && @clock < @duration
        @roots.each do |r|
          make(r.move)
          r.score = -alphabeta(-INF, INF, @height)
          unmake(r.move)
        end

        @nph << @npp.inject(:+) - @nodes
        @nodes += @nph.last
        @root = @roots.sort!.first
        @clock = Time.now - start_time
        @height += 1
      end
    end

    #
    def alphabeta(alpha, beta, depth)
      @npp[@ply] += 1
      return evaluate(@mx) if depth == 0

      generate_moves.each do |m|
        next unless make(m)
        x = -alphabeta(-beta, -alpha, depth - 1)
        unmake(m)

        if x > alpha
          update_history(m, depth)
          return beta if x >= beta
          alpha = x
        end
      end

      alpha
    end

    #
    def each_move(i)
      piece, color = @squares[i], @colors[i]

      if piece == P
        to = i + DIR[color]
        yield(to - 1, P, @squares[to - 1]) if SQ120[SQ64[to] - 1] != NULL && @colors[to - 1] == color ^ 1
        yield(to + 1, P, @squares[to + 1]) if SQ120[SQ64[to] + 1] != NULL && @colors[to + 1] == color ^ 1
        return unless @colors[to] == EMPTY

        yield(to, P, EMPTY)
        to += DIR[color]
        yield(to, P, EMPTY) if @squares[to] == EMPTY && !R3_6.cover?(i)

      else STEPS[piece].each do |step|
          to = SQ120[SQ64[i] + step]

          while to != NULL
            if @colors[to] == EMPTY
              yield(to, piece, EMPTY)
              break unless SLIDES[piece]

              to = SQ120[SQ64[to] + step]
              next
            elsif @colors[to] == color ^ 1
              yield(to, piece, @squares[to])
            end
            break
          end
        end
      end
    end

    #
    def generate_moves
      @moves[@ply].clear.tap do |moves|
        64.times do |from|
          next unless @colors[from] == @mx
          each_move(from) do |to, piece, target|
            score = target == EMPTY ? @history[@ply][piece][to] : 200_000 + target - piece
            moves << Move.new(from, to, piece, target, score).freeze
          end
        end
        moves.sort!
      end
    end

    #
    def evaluate(side)
      @evaluation = 0
      each_piece do |from, piece, color|
        @evaluation += SWAP[side][color] * (CENTER[from] + VAL[piece] + POS[piece][from * FLIP[color]])
      end
      @evaluation
    end

    #
    def make(m)
      @ply += 1
      @squares[m.to], @colors[m.to] = m.piece, @mx
      @squares[m.from], @colors[m.from] = EMPTY, EMPTY
      @squares[m.to] = Q if m.piece == P && !R2_7.cover?(m.to)
      @kings[@mx] = m.to if m.piece == K
      @mx, @mn = @mn, @mx

      return unmake(m) if in_check?(@mn)
      true
    end

    #
    def unmake(m)
      @ply -= 1
      @mx, @mn = @mn, @mx
      @colors[m.from], @squares[m.from] = @mx, m.piece
      @kings[@mx] = m.from if m.piece == K
      @colors[m.to], @squares[m.to] = EMPTY, m.target
      @colors[m.to] = @mn unless m.target == EMPTY
      false
    end

    #
    def in_check?(side)
      k = @kings[side]

      OCTL.each_with_index do |step, i|
        n = SQ120[SQ64[k] + STEP[i]]
        return true if n != NULL && @squares[n] == N && @colors[n] == side ^ 1

        n = SQ120[SQ64[k] + step]
        n = SQ120[SQ64[n] + step] while n != NULL && @colors[n] == EMPTY
        next if n == NULL || @colors[n] != side ^ 1

        case @squares[n]
        when Q then return true
        when B then return true if i < 4
        when R then return true if i > 3
        when P then return true if (k - n + DIR[side]).abs == 1
        when K then return true if SQ120[SQ64[k] + step] == n
        end
      end

      false
    end

  end
end
