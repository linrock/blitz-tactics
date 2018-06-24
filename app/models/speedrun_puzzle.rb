# a puzzle for a speedrun level

class SpeedrunPuzzle < ActiveRecord::Base
  include PuzzleRecord

  belongs_to :speedrun_level
  has_many :solved_speedrun_puzzles, dependent: :destroy
end
