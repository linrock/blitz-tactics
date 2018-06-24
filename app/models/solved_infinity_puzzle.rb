# tracks the puzzles that a user has solved

class SolvedInfinityPuzzle < ActiveRecord::Base
  belongs_to :infinity_puzzle
  belongs_to :user

  validates :difficulty, inclusion: InfinityLevel::DIFFICULTIES

  default_scope { order(updated_at: :desc) } # first = latest solved

  scope :with_difficulty, -> (difficulty) do
    where(difficulty: difficulty)
  end
end
