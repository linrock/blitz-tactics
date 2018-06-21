# creates a puzzle from the new lichess puzzle data format

class NewLichessPuzzle < ActiveRecord::Base
  include PuzzleQuery

  has_many :infinity_puzzles
  has_many :solved_infinity_puzzles

  before_validation :set_puzzle_id_from_data
  validates :puzzle_id, presence: true, uniqueness: true
  validate :check_simplified_data_format

  def self.find_or_create_from_raw_data(json_data)
    data = json_data["data"]
    puzzle_id = data["puzzle"]["id"]
    existing_puzzle = NewLichessPuzzle.find_by(puzzle_id: puzzle_id)
    if existing_puzzle.present?
      existing_puzzle
    else
      NewLichessPuzzle.create!(data: data)
    end
  end

  def fen
    data["puzzle"]["fen"]
  end

  def simplified_data
    initial_move = data["game"]["treeParts"][-1]
    data["puzzle"].slice("fen", "lines").merge({
      "initialMove": initial_move.slice("san", "uci"),
      "id": id
    })
  end
 
  private

  def set_puzzle_id_from_data
    self.puzzle_id = data["puzzle"]["id"]
  end

  def check_simplified_data_format
    simplified_data.all? {|_, v| v.present? }
  end
end
