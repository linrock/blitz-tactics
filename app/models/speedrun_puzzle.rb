class SpeedrunPuzzle < ActiveRecord::Base
  belongs_to :speedrun_level
  belongs_to :new_lichess_puzzle

  validates :new_lichess_puzzle, presence: true

  delegate :fen, :initial_move, :initial_move_uci, :simplified_data,
           to: :new_lichess_puzzle

  alias puzzle new_lichess_puzzle
end
