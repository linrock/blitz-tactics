# tracks the puzzles that a user has solved

class SolvedInfinityPuzzle < ActiveRecord::Base
  belongs_to :user

  validates :difficulty, inclusion: %w( easy medium hard insane )

  scope :with_difficulty, -> (difficulty) do
    where(difficulty: difficulty)
  end

  scope :latest_solved, -> do
    order('updated_at DESC').first
  end
end
