class LichessPuzzle < ActiveRecord::Base
  include PuzzleQuery

  def self.load_from_json_files!
    files = Dir.glob(Rails.root.join("data/lichess/*.json"))
    files.sort_by {|path| path[/\d+/].to_i }.each do |file|
      puzzle_id = file[/(\d+)\.json/, 1].to_i
      next if LichessPuzzle.exists?(:puzzle_id => puzzle_id)
      data = open(file).read.strip
      begin
        LichessPuzzle.create!(:puzzle_id => puzzle_id, :data => JSON.parse(data))
      rescue
        `rm #{file}`
      end
    end
    nil
  end

  def self.from_puzzle_ids(puzzle_ids)
    puzzles = []
    puzzle_ids.each {|id| puzzles << find_by(puzzle_id: id) }
    puzzles
  end

  def fen
    data.dig("puzzle", "fen")
  end

  def initial_move_uci
    data.dig("puzzle", "initialMove")
  end

  def rating
    data.dig("puzzle", "rating")
  end

  # New minimal data format
  def simplified_data
    data["puzzle"].slice("fen", "initialMove", "lines")
  end
end
