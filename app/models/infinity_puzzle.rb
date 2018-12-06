# a puzzle for an infinity level

class InfinityPuzzle < ActiveRecord::Base
  include PuzzleRecord

  belongs_to :infinity_level
  has_many :solved_infinity_puzzles, dependent: :destroy

  validates :puzzle_hash, uniqueness: true
end
