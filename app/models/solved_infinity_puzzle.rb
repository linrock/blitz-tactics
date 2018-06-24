# tracks the puzzles that a user has solved

class SolvedInfinityPuzzle < ActiveRecord::Base
  belongs_to :user
  belongs_to :new_lichess_puzzle

  validates :new_lichess_puzzle, presence: true
  validates :difficulty, inclusion: InfinityLevel::DIFFICULTIES

  default_scope { order('updated_at ASC') } # first = personal best

  scope :with_difficulty, -> (difficulty) do
    where(difficulty: difficulty)
  end
end
