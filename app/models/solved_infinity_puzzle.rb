# tracks the puzzles that a user has solved

class SolvedInfinityPuzzle < ActiveRecord::Base
  belongs_to :infinity_puzzle
  belongs_to :user

  validates :difficulty, inclusion: InfinityLevel::DIFFICULTIES

  scope :most_recent_last, -> do # last = latest solved
    order(updated_at: :asc)
  end

  scope :with_difficulty, -> (difficulty) do
    where(difficulty: difficulty)
  end
end
