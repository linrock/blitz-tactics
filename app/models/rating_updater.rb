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
      logger.info "#{@user_rating.user.username} - #{outcome} - #{@user_rating.rating.round} -> #{player_g2.rating.round} (#{@user_rating.rating_deviation.round} -> #{player_g2.rating_deviation.round})"
      logger.info "#{@user_rating.user.username} - moves #{uci_moves}"
      logger.info "#{@user_rating.user.username} - time #{elapsed_time_ms / 1000.to_f}s"
      logger.info "puzzle #{@rated_puzzle.id} - #{@rated_puzzle.rating.round} -> #{puzzle_g2.rating.round} (#{@rated_puzzle.rating_deviation.round} -> #{puzzle_g2.rating_deviation.round})"
      @user_rating.update!({
        rating: player_g2.rating,
        rating_deviation: player_g2.rating_deviation,
        rating_volatility: player_g2.volatility,
      })
      @rated_puzzle.update!({
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
    threshold = 7_000 + (uci_moves.length - 1) / 2 * 3_000
    if result == "win"
      elapsed_time_ms < threshold ? "win" : "draw"
    else
      "loss"
    end
  end

  private

  # favors players - max loss of 19 points, gain at least 1 point for a draw
  def modify_player_g2(player_g2, outcome)
    if outcome == "draw" && player_g2.rating < @user_rating.rating + 1
      Rating.new(
        @user_rating.rating + 1,
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
    user_rating = user.user_rating
    if user_rating.nil?
      return user.create_user_rating!
    elsif user_rating.new_record?
      user_rating.save!
    end
    user_rating
  end

  def logger
    @logger ||= Logger.new("#{Rails.root}/log/rated_puzzles.log")
  end
end
