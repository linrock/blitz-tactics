class RatedPuzzle < ActiveRecord::Base
  include PuzzleRecord

  has_many :rated_puzzle_attempts

  def try_uci_moves(uci_moves)
    "win"
  end
end
