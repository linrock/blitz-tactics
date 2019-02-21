# rated mode puzzles

class GameModes::RatedController < ApplicationController
  before_action :require_logged_in_user!

  def index
    @user_rating = current_user.user_rating || current_user.build_user_rating
    render "game_modes/rated"
  end

  # json endpoint for fetching puzzles on initial pageload
  def puzzles
    render json: {
      puzzles: RatedPuzzle.all.limit(100)
    }
  end

  # user has attempted a rated puzzle
  def attempt
    rated_puzzle = RatedPuzzle.find puzzle_attempt_params[:id]
    rating_updater = RatingUpdater.new(current_user, rated_puzzle)
    rated_puzzle_attempt = rating_updater.attempt!(puzzle_attempt_params)
    render json: {
      rated_puzzle_attempt: rated_puzzle_attempt
    }
  end

  private

  def puzzle_attempt_params
    params.require(:puzzle_attempt).permit(
      :id,
      :elapsed_time_ms,
      :uci_moves => []
    )
  end
end
