class RatedPuzzleAttempt < ApplicationRecord
  # outcomes from the user's perspective vs. the puzzle
  OUTCOMES = %w( win loss draw )

  belongs_to :user_rating
  belongs_to :rated_puzzle

  validates :uci_moves, presence: true
  validates :outcome, inclusion: OUTCOMES

  Rating = Struct.new(:rating, :rating_deviation, :volatility)

  # entry point for creating puzzle attempts + updating ratings
  def self.attempt!(user_rating, rated_puzzle, uci_moves)
    ActiveRecord::Transaction do
      player_g2 = Rating.new(
        user_rating.rating,
        user_rating.rating_deviation,
        user_rating.rating_volatility
      )
      puzzle_g2 = Rating.new(
        rated_puzzle.rating,
        rated_puzzle.rating_deviation,
        rated_puzzle.rating_volatility
      )
      puzzle_attempt_attributes = {
        user_rating_id: user_rating.id,
        rated_puzzle_id: rated_puzzle.id,
        uci_moves: uci_moves,
        outcome: outcome, 
        pre_user_rating: user_rating.rating,
        pre_user_rating_deviation: user_rating.rating_deviation,
        pre_user_rating_volatility: user_rating.rating_volatility,
        pre_puzzle_rating: rated_puzzle.rating,
        pre_puzzle_rating_deviation: rated_puzzle.rating_deviation,
        pre_puzzle_rating_volatility: rated_puzzle.rating_volatility,
      })
      ranking = case outcome
        when "win" then [1, 2]
        when "loss" then [2, 1]
        when "draw" then [1, 1]
      end
      rating_period = Glicko2::RatingPeriod.from_objs([player_g2, puzzle_g2])
      rating_period.game([player_g2, puzzle_g2], ranking)
      next_rating_period = rating_period.generate_next(0.5)
      next_rating_period.players.each(&:update_obj)
      user_rating.update_attributes!({
        rating: player_g2.rating,
        rating_deviation: player_g2.rating_deviation,
        rating_volatility: player_g2.rating_volatility,
      })
      rated_puzzle.update_attributes!({
        rating: puzzle_g2.rating,
        rating_deviation: puzzle_g2.rating_deviation,
        rating_volatility: puzzle_g2.rating_volatility,
      })
      RatedPuzzleAttempt.create!(
        puzzle_attempt_attributes.merge({
          post_user_rating: player_g2.rating,
          post_user_rating_deviation: player_g2.rating_deviation,
          post_user_rating_volatility: player_g2.rating_volatility,
          post_puzzle_rating: puzzle_g2.rating,
          post_puzzle_rating_deviation: puzzle_g2.rating_deviation,
          post_puzzle_rating_volatility: puzzle_g2.rating_volatility,
        })
      )
    end
  end
end
