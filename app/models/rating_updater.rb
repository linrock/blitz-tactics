# Updates ratings for players and puzzles

class RatingUpdater
  TAU = 0.5   # glicko2 system constant - 0.3 to 1.2

  Rating = Struct.new(:rating, :rating_deviation, :volatility)

  def initialize(user, rated_puzzle)
    @user_rating = init_user_rating(user)
    @rated_puzzle = rated_puzzle
  end

  # entry point for creating puzzle attempts + updating ratings
  def attempt!(options)
    uci_moves = options[:uci_moves]
    elapsed_time_ms = options[:elapsed_time_ms]
    ActiveRecord::Base.transaction do
      player_g2 = Rating.new(
        @user_rating.rating,
        @user_rating.rating_deviation,
        @user_rating.rating_volatility
      )
      puzzle_g2 = Rating.new(
        @rated_puzzle.rating,
        @rated_puzzle.rating_deviation,
        @rated_puzzle.rating_volatility
      )
      outcome = get_outcome(uci_moves, elapsed_time_ms)
      puzzle_attempt_attributes = {
        user_rating_id: @user_rating.id,
        rated_puzzle_id: @rated_puzzle.id,
        uci_moves: uci_moves,
        outcome: outcome,
        elapsed_time_ms: elapsed_time_ms,
        pre_user_rating: @user_rating.rating,
        pre_user_rating_deviation: @user_rating.rating_deviation,
        pre_user_rating_volatility: @user_rating.rating_volatility,
        pre_puzzle_rating: @rated_puzzle.rating,
        pre_puzzle_rating_deviation: @rated_puzzle.rating_deviation,
        pre_puzzle_rating_volatility: @rated_puzzle.rating_volatility,
      }
      ranking = case outcome
        when "win" then [1, 2]
        when "loss" then [2, 1]
        when "draw" then [1, 1]
      end
      rating_period = Glicko2::RatingPeriod.from_objs([player_g2, puzzle_g2])
      rating_period.game([player_g2, puzzle_g2], ranking)
      next_rating_period = rating_period.generate_next(TAU)
      next_rating_period.players.each(&:update_obj)
      player_g2 = modify_player_g2(player_g2, outcome)
      rated_puzzle_attempt = RatedPuzzleAttempt.create!(
        puzzle_attempt_attributes.merge({
          post_user_rating: player_g2.rating,
          post_user_rating_deviation: player_g2.rating_deviation,
          post_user_rating_volatility: player_g2.volatility,
          post_puzzle_rating: puzzle_g2.rating,
          post_puzzle_rating_deviation: puzzle_g2.rating_deviation,
          post_puzzle_rating_volatility: puzzle_g2.volatility,
        })
      )
      @user_rating.update_attributes!({
        rating: player_g2.rating,
        rating_deviation: player_g2.rating_deviation,
        rating_volatility: player_g2.volatility,
      })
      @rated_puzzle.update_attributes!({
        rating: puzzle_g2.rating,
        rating_deviation: puzzle_g2.rating_deviation,
        rating_volatility: puzzle_g2.volatility,
      })
      rated_puzzle_attempt
    end
  end

  # win, loss, draw - player's perspective vs. puzzle
  def get_outcome(uci_moves, elapsed_time_ms)
    result = @rated_puzzle.result_of_uci_moves(uci_moves)
    if result == "win"
      elapsed_time_ms < 7_000 ? "win" : "draw"
    else
      "loss"
    end
  end

  private

  # player - max loss of 19 points, gain at least half a point for a draw
  def modify_player_g2(player_g2, outcome)
    if outcome == "draw" && player_g2.rating < @user_rating.rating + 0.5
      Rating.new(
        @user_rating.rating + 0.5,
        @user_rating.rating_deviation,
        @user_rating.rating_volatility
      )
    elsif outcome == "loss"
      Rating.new(
        [@user_rating.rating - 19, player_g2.rating].max,
        player_g2.rating_deviation,
        player_g2.volatility
      )
    else
      player_g2
    end
  end

  def init_user_rating(user)
    user.user_rating || user.create_user_rating
  end
end
