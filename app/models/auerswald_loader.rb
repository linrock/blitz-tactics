class AuerswaldLoader


  class Puzzle

    attr_accessor :fen, :pgn, :moves, :turn

    def initialize(pgn)
      @fen   = pgn[/FEN "(.*)"/, 1]
      @pgn   = pgn.split(/\r\n\r/)[1].strip
      @turn  = @pgn[/^\d+\.{3}/] && 'b' || 'w'
      @moves = @pgn.
                 gsub(/\(.*\)/, '').
                 gsub(/\{.*\}/, '').
                 gsub(/\d+\.{1,3}/, '').
                 gsub(/\d\-\d/, '').
                 strip.split(/\s+/)
    end

    def to_h
      {
        :fen   => @fen,
        :moves => @moves,
        :turn  => @turn
      }
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
