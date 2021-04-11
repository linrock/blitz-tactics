# a puzzle for a repetition level

class RepetitionPuzzle < ActiveRecord::Base
  include PuzzleRecord

  belongs_to :repetition_level

  default_scope { order('id ASC') }

  validates :puzzle_hash, uniqueness: true
end
