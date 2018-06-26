# a puzzle for a speedrun level

class SpeedrunPuzzle < ActiveRecord::Base
  include PuzzleRecord

  belongs_to :speedrun_level
end
