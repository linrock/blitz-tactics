# a puzzle for a countdown level

class CountdownPuzzle < ActiveRecord::Base
  include PuzzleRecord

  belongs_to :countdown_level, touch: true

  validates :puzzle_hash, uniqueness: { scope: :countdown_level_id }
end
