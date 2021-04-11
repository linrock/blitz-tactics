# Represents a chess puzzle. Puzzles can be viewed online from their
# corresponding link based on their puzzle_id:
# https://blitztactics.com/p/:puzzle_id
#
#  puzzle_data schema:
#    { "fen": FEN | null,
#      "initial_move_san": (string | null),
#      "initial_move_uci": (string | null),
#      "puzzle_fen": FEN | null,
#      "lines": { [uci_move: "lines"] } }

class Puzzle < ActiveRecord::Base
  include PuzzleQuery

  has_many :puzzle_reports

  # Each puzzle is uniquely hashed based on their puzzle data
  validates :puzzle_data_hash, presence: true
  # Puzzle data consists of - initial_fen, initial_move_san, initial_move_uci, puzzle_fen, lines
  validates :puzzle_data, presence: true
  before_create :recalculate_and_set_puzzle_data_hash
  before_save :recalculate_and_set_puzzle_data_hash

  # puzzle format used by blitz tactics game modes
  def bt_puzzle_data
    {
      id: id,
      fen: puzzle_data["initial_fen"],
      lines: puzzle_data["lines"],
      initialMove: {
        san: puzzle_data["initial_move_san"],
        uci: puzzle_data["initial_move_uci"],
      }
    }
  end

  def fen
    puzzle_data["initial_fen"]
  end

  def initial_move_san
    puzzle_data["initial_move_san"]
  end

  # Any string that can be used to uniquely identify a puzzle
  def self.find_by_id(puzzle_id)
    Puzzle.find_by(puzzle_id: puzzle_id)
  end

  # Sorts puzzles by the order in which they show up in puzzle_ids
  def self.find_by_sorted(puzzle_ids)
    puzzle_ids = puzzle_ids.map(&:to_i)
    Puzzle.where(id: puzzle_ids).sort_by { |p| puzzle_ids.index(p.id) }
  end

  # Generate a unique for the puzzle based on the input puzzle data
  def self.data_hash(puzzle_data)
    Digest::MD5.hexdigest(puzzle_data.to_json)[0..8]
  end

  # Create a puzzle from some parsed JSON data
  def self.create_or_find_from_puzzle_data(data)
    puzzle = Puzzle.find_by(
      puzzle_data_hash: Puzzle.data_hash(data[:puzzle_data])
    )
    return puzzle if puzzle.present?
    Puzzle.create!({
      puzzle_data: data[:puzzle_data],
      metadata: data[:metadata]
    })
  end

  # Goes through all existing puzzles and creates a Puzzle
  # out of any puzzles that haven't been seen before
  def self.populate_from_existing_puzzles
  end

  # Tries to parse a file glob as a set of source puzzle data files
  # Currently unused
  def self.populate_from_json_files(glob)
    Dir.glob(glob).each do |filename|
      json_file_data = JSON.parse(filename)
      json_file_data.each do |json_file_row_data|
        # Lichess Puzzle json data format - fen, initialMove (san, uci), lines, id
        Puzzle.create_or_find_from_puzzle_data({
          # The positions in a puzzle uniquely identify it
          puzzle_data: {
            initial_fen: json_file_row_data["fen"],
            initial_move_san: json_file_row_data["initialMove"]["san"],
            initial_move_uci: json_file_row_data["initialMove"]["uci"],
            puzzle_fen: nil,
            lines: json_file_row_data["lines"]
          },
          metadata: {
            source: "lichess",
            lichess_puzzle_id: json_file_row_data["id"]
          }
        })
      end
    end
  end

  private

  def recalculate_and_set_puzzle_data_hash
    self.puzzle_data_hash = Puzzle.data_hash(self.puzzle_data)
  end
end