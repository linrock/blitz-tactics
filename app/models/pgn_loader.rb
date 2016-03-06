class TacticsLoader


  class Puzzle

    attr_accessor :fen, :pgn, :moves, :turn

    def initialize(pgn)
      @fen   = pgn[/FEN "(.*)"/, 1]
      @pgn   = pgn.split(/\r\n\r/)[1].strip
      @turn  = @pgn[/^\d+\.{3}/] && 'b' || 'w'
      @moves = @pgn.
                 gsub(/\n/, ' ').
                 gsub(/\(.*\)/, '').
                 gsub(/\{.*\}/, '').
                 gsub(/\d+\.{1,3}/, '').
                 gsub(/\$\d+/, '').
                 gsub('1/2-1/2', '').
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


  def self.query(options = {})
    offset = options[:offset] || 0
    puzzles = []
    self.new.all_puzzles.each do |puzzle|
      next unless puzzle.turn == options[:turn]
      puzzles << puzzle.to_h
      break if puzzles.length >= options[:n] + offset
    end
    puzzles[offset..-1]
  end

  def initialize
    @data = open(Rails.root.join("data/auerswald.pgn"), 'r').read
  end

  def all_puzzles
    @data.split('[Event ')[1..-1].map do |pgn|
      Puzzle.new(pgn)
    end
  end

end
