class RatedPuzzleAttempt < ActiveRecord::Base
  # outcomes from the player's perspective vs. the puzzle
  OUTCOMES = %w( win loss draw )

  UCI_MOVE_REGEX = /([a-h][1-8]){2}(qpnbr)?/

  belongs_to :user_rating, counter_cache: true
  belongs_to :rated_puzzle, counter_cache: true

  validates :uci_moves, presence: true
  validates :elapsed_time_ms, presence: true
  validates :outcome, inclusion: OUTCOMES
  validate :check_uci_moves_format

  private

  def check_uci_moves_format
    if uci_moves.any? {|move| move !~ UCI_MOVE_REGEX }
      errors.add :uci_moves, "has invalid moves - #{uci_moves}"
    end
  end
end
