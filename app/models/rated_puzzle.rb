class RatedPuzzle < ActiveRecord::Base
  include PuzzleRecord

  has_many :rated_puzzle_attempts

  # selects a set of rated puzzles for a given user id
  def self.for_user(user)
    user_rating = user.user_rating
    if user_rating
      unseen_puzzles = RatedPuzzle.where("
        id NOT IN (
          SELECT rated_puzzle_id FROM rated_puzzle_attempts
          WHERE rated_puzzle_attempts.user_rating_id = ?
        )
      ", user_rating.id).order('rating ASC').limit(10)
      rating = user_rating.rating
      similar_rating_puzzles = RatedPuzzle.where(
        "rating >= ? AND rating <= ?", rating - 50, rating + 50
      ).limit(10)
      (unseen_puzzles + similar_rating_puzzles).uniq.shuffle
    else
      RatedPuzzle.order('rating ASC').limit(20)
    end
  end

  # try a sequence of moves and see if the player won or lost
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
