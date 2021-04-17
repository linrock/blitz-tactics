class PuzzleSet < ActiveRecord::Base
  has_and_belongs_to_many :lichess_v2_puzzles
end