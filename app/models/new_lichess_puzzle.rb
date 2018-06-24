# creates a puzzle from the new lichess puzzle data format

class NewLichessPuzzle < ActiveRecord::Base
  include PuzzleQuery

  has_many :infinity_puzzles
  has_many :solved_infinity_puzzles

  before_validation :set_puzzle_id_from_data
  validates :puzzle_id, presence: true, uniqueness: true
  validate :check_data_fields
  validate :check_simplified_data_format

  def self.find_or_create_from_raw_data(json_data)
    puzzle_id = json_data["puzzle"]["id"]
    existing_puzzle = NewLichessPuzzle.find_by(puzzle_id: puzzle_id)
    if existing_puzzle.present?
      existing_puzzle
    else
      NewLichessPuzzle.create!(data: json_data)
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

  def rating
    data["puzzle"]["rating"]
  end

  def simplified_data
    data["puzzle"].slice("fen", "lines").merge({
      "initialMove": initial_move,
      "id": puzzle_id
    })
  end
 
  private

  def set_puzzle_id_from_data
    self.puzzle_id = data["puzzle"]["id"]
  end

  def check_data_fields
    errors.add(:data, "is missing fen") unless fen.present?
    errors.add(:data, "is missing initial move") unless initial_move.present?
    errors.add(:data, "is missing initial move uci") unless initial_move_uci.present?
    errors.add(:data, "is missing rating") unless rating.present?
  end

  def check_simplified_data_format
    unless simplified_data.all? {|_, v| v.present? }
      errors.add(:data, "is invalid")
    end
  end
end
