# a puzzle for a speedrun level

class SpeedrunPuzzle < ActiveRecord::Base
  include PuzzleRecord

  belongs_to :speedrun_level, touch: true

  validates :puzzle_hash, uniqueness: { scope: :speedrun_level_id }
end
