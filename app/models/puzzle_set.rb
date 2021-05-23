class PuzzleSet < ActiveRecord::Base
  belongs_to :user
  has_many :lichess_v2_puzzles_puzzle_sets
  has_many :lichess_v2_puzzles, through: :lichess_v2_puzzles_puzzle_sets

  def textarea_puzzle_ids
    lichess_v2_puzzles.pluck(:puzzle_id).join("\n")
  end
end