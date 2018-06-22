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

  def initial_move
    data["game"]["treeParts"][-1].slice("san", "uci")
  end

  def initial_move_uci
    initial_move["uci"]
  end

  def simplified_data
    data["puzzle"].slice("fen", "lines").merge({
      "initialMove": initial_move,
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
