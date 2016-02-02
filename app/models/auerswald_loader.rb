class AuerswaldLoader


  class Puzzle

    attr_accessor :fen, :moves, :turn

    def initialize(pgn)
      @fen = pgn[/FEN "(.*)"/, 1]
      @moves = pgn.split(/\r\n\r/)[1].strip
      @turn = @moves[/^\d+\.{3}/] && 'b' || 'w'
    end

  end


  def initialize
    @data = open(Rails.root.join("data/auerswald.pgn"), 'r').read
  end

  def puzzles
    @data.split('[Event ')[1..-1].map do |pgn|
      Puzzle.new(pgn)
    end
  end

end
