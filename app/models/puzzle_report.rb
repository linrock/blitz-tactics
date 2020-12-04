# For reporting bad puzzles

class PuzzleReport < ActiveRecord::Base
  belongs_to :puzzle
  belongs_to :user
end
