class RatedPuzzle < ActiveRecord::Base
  include PuzzleRecord

  has_many :rated_puzzle_attempts

  def self.unseen(user_rating)
    where("
      id NOT IN (
        SELECT rated_puzzle_id FROM rated_puzzle_attempts
        WHERE rated_puzzle_attempts.user_rating_id = ?
      )
    ", user_rating.id)
  end

  def self.rating_range(low, high)
    where("rating >= ? AND rating <= ?", low, high)
  end

  # selects a set of rated puzzles for a given user id
  def self.for_user(user)
    user_rating = user.user_rating
    if user_rating
      unseen_puzzles = RatedPuzzle
        .unseen(user_rating)
        .order('rating ASC')
        .limit(10)
      rating_value = user_rating.rating
      similar_rating_puzzles = RatedPuzzle
        .unseen(user_rating)
        .rating_range(rating_value - 50, rating_value + 50)
        .limit(10)
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
