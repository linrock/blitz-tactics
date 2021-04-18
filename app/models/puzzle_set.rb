class PuzzleSet < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :lichess_v2_puzzles

  def textarea_puzzle_ids
    lichess_v2_puzzles.pluck(:puzzle_id).join("\n")
  end
end