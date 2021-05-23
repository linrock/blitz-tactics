class PuzzleSet < ActiveRecord::Base
  belongs_to :user
  has_many :lichess_v2_puzzles_puzzle_sets
  has_many :lichess_v2_puzzles, through: :lichess_v2_puzzles_puzzle_sets

  PUZZLE_LIMIT = 25_000  # arbitrary limit on # of puzzles per puzzle set

  def textarea_puzzle_ids
    lichess_v2_puzzles.pluck(:puzzle_id).join("\n")
  end
end