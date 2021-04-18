class PuzzleSet < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :lichess_v2_puzzles
end