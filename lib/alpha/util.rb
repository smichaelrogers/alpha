module Alpha
  class Engine
    #
    def load_position(fen = FEN_INITIAL)
      @fen = fen
      parts = fen.split
      board = parts.first.gsub(/[1-8]/) { |s| '_' * s.to_i }

      if parts.length > 1 && fen =~ FEN_REGEXP && board.split('/').count { |s| s.length == 8 } == 8
        @mx = COLORS.index(parts[1])
        @turn = parts[5] && parts[5] =~ /\A[-+]?\d+\z/ ? parts[5].to_i + 1 : 1
        board.delete!('/')

        @kings = [board.index('K'), board.index('k')]
        @colors = board.chars.map { |s| FEN_KEY[s][0] }
        @squares = board.chars.map { |s| FEN_KEY[s][1] }
      end

      @mx && @kings.length == 2 && @colors.length == 64 && @squares.length == 64
    end

    #
    def render_fen
      board = []
      8.times do |i|
        empty = 0
        8.times do |j|
          if @colors[(i*8)+j] == EMPTY
            empty += 1
            board << empty if j == 7
          else
            board << empty if empty > 0
            empty = 0
            board << PIECES[@colors[(i*8)+j]][@squares[(i*8)+j]]
          end
        end
        board << '/' if i <  7
      end
      "#{board.join} #{COLORS[@mx]} - - 0 #{@turn}"
    end

    #
    def each_piece
      64.times { |i| yield(i, @squares[i], @colors[i]) if @colors[i] != EMPTY }
    end

    #
    def board
      (0..63).map { |i| PIECES[@colors[i] % 6][@squares[i]] }
    end

    #
    def result
      @roots.empty? ? (in_check?(@mx) ? COLORS[@mn] : 'draw') : 'ongoing'
    end

    #
    def ready
      @roots && @roots.any? && result == 'ongoing'
    end

    #
    def update_history(m, depth)
      return unless m.target == EMPTY
      @history[@ply][m.piece][m.to] += depth + @height**2
    end

    #
    def render_board
      (0..7).map { |i| "\033[90m#{RANKS[i]}\033[0m " + (0..7).map { |j|
          UNICODE[@colors[(i * 8) + j] % 6][@squares[(i * 8) + j]] }.map.with_index { |sq, j|
            @root && (i * 8) + j == @root.move.to ? "\033[96;1m#{sq}\033[0m" : sq
          }.join(' ')
        } << "  \033[90m#{FILES.join(' ')}\033[0m"
    end

    #
    def render
      lines = render_board

      { 'Turn'  => @turn - 1,
        'SAN'   => @root.san,
        'Score' => "#{@root.score}(#{(@roots.map { |r| r.score }.inject(:+) / @roots.length.to_f).round(2)} avg)",
        'Clock' => @clock.round(2),
        'Nodes' => @nodes,
        'NPS'   => (@nodes.to_f / @clock).round(2),
        'NPH'   => @nph.join(" \033[90m❯\033[0m "),
        'NPP'   => @npp.select { |n| n > 0 }.join(" \033[90m❯\033[0m "),
        'Eval'  => evaluate(@mn) }.
        each_with_index { |h, i| lines[i] << "\033[90m │ #{h[0].ljust(5, ' ')}\033[0m #{h[1]}" }

      lines.unshift("\n\n", "#{COLOR_NAMES[@mn]} makes move #{@root.to_s}", "\033[90m#{'─' * 18}┬#{'─' * 32}\033[0m")
      lines.map { |l| " #{l}" }.join("\n")
    end

    #
    def to_h
      {
        turn: @turn - 1,
        clock: @clock.round(2),
        nodes: @nodes,
        nps: (@nodes.to_f / @clock).round(2),
        nph: @nph,
        npp: @npp,
        evaluation: evaluate(@mn),
        moves: @roots.map { |r| r.to_h }
      }.merge(@root.to_h)
    end

  end
end
