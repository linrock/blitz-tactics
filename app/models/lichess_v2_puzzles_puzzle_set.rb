class LichessV2PuzzlesPuzzleSet < ActiveRecord::Base
  belongs_to :lichess_v2_puzzle
  belongs_to :puzzle_set
end