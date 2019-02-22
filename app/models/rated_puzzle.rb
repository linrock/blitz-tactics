class RatedPuzzle < ActiveRecord::Base
  include PuzzleRecord

  has_many :rated_puzzle_attempts

  # try a sequence of moves and see what the outcome is
  def result_of_uci_moves(uci_moves)
    node = lines
    uci_moves.each do |uci_move|
      next if node[uci_move] == "retry"
      node = node[uci_move]
      return "loss" if node.nil?
    end
    if node == "win" || node.values.any? {|n| n == "win" }
      "win"
    else
      "loss"
    end
  end
end
