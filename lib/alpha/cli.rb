module Alpha

  def self.generate_search_data(fen = FEN_INITIAL)
    e = Engine.new
    return unless fen && e.load_position(fen)
    e.reset!
    
    if e.ready
      e.search
      e.make(e.root.move)
      e.turn += 1
      e.to_h
    end
  end

  #
  def self.play(turns: 500, duration: 1, fen: FEN_INITIAL, human: false, pp: false)
    e = Engine.new
    e.duration = duration
    session = []

    return unless e.load_position(fen)
    e.reset!

    while e.ready && e.turn < turns
      e.search
      e.make(e.root.move)
      system('clear')
      e.turn += 1

      puts ap(e.to_h) if pp
      session << e.to_h
      puts e.render
      e.reset!

      if human && e.ready
        puts "\n\n Input move#{' (ex. nf3 NF3 e4 etc.)'.ansi_grey }\n\n"

        puts e.roots.map { |r| r.to_s.ljust(30, ' ') }.each_slice(3).map { |n|
          n.map { |m| m.ljust(30, ' ') }.join(' ') }.join("\n")

        while true
          e.root = nil
          san = gets.chomp.downcase
          e.root = e.roots.find { |r| r.san.downcase == san }
          break if e.root

          puts "Could not find move: #{san}\nTry again"
        end

        e.make(e.root.move)
        puts e.render_board
        e.turn += 1
        e.reset!
      end
    end

    # File.open('./log.json', 'w') { |f| session.each { |turn| f.puts turn.to_json } }
  end
end
