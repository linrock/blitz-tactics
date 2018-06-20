class CompletedInfinityPuzzle < ActiveRecord::Base
  belongs_to :user

  validates :difficulty, inclusion: %w( easy medium hard insane )

  scope :with_difficulty, -> (difficulty) do
    where(difficulty: difficulty)
  end

  scope :latest, -> do
    order('updated_at DESC').first
  end
end
