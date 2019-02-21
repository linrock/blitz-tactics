class RatedPuzzleAttempt < ActiveRecord::Base
  # outcomes from the player's perspective vs. the puzzle
  OUTCOMES = %w( win loss draw )

  belongs_to :user_rating, counter_cache: true
  belongs_to :rated_puzzle, counter_cache: true

  validates :uci_moves, presence: true
  validates :elapsed_time_ms, presence: true
  validates :outcome, inclusion: OUTCOMES
end
