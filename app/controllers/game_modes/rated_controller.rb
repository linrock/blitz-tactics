# rated mode puzzles

class GameModes::RatedController < ApplicationController
  before_action :require_logged_in_user!

  def index
    user_rating
    render "game_modes/rated"
  end

  # GET /rated/puzzles.json - for fetching puzzles on initial pageload
  def puzzles_json
    puzzles = RatedPuzzle.for_user(current_user)
    unless params[:next].present?
      puzzles = [RepetitionLevel.number(1).first_puzzle] + puzzles
    end
    render json: {
      puzzles: puzzles
    }
  end

  # TODO: GET /rated/puzzles - a page for recently-played rated puzzles
  def puzzles
    puzzle_ids = current_user.user_rating.
      rated_puzzle_attempts.order('id DESC').limit(30).
      includes(:rated_puzzle).map(&:rated_puzzle).compact.map {|p| p.data["id"] }
    @puzzles = Puzzle.find_by_sorted(puzzle_ids)
  end

  # GET /rated/attempts - view recent puzzle attempts
  def puzzle_attempts_list
    @puzzle_attempts = user_rating
      .rated_puzzle_attempts.order('id DESC').limit(30)
  end

  # GET /rated/attempts/:id - view a puzzle attempt
  def puzzle_attempt
    @puzzle_attempt = user_rating.rated_puzzle_attempts
      .find_by(id: params[:id])
  end

  # POST /rated/attempts - player submits a puzzle attempt after a puzzle
  def attempt
    rated_puzzle = RatedPuzzle.find puzzle_attempt_params[:id]
    if user_rating.rated_puzzle_attempts.exists?(rated_puzzle_id: rated_puzzle.id)
      render status: 400, json: {
        error: "Puzzle #{rated_puzzle.id} already attempted"
      }
      return
    end
    rating_updater = RatingUpdater.new(current_user, rated_puzzle)
    rated_puzzle_attempt = rating_updater.attempt!(puzzle_attempt_params)
    render json: {
      rated_puzzle_attempt: rated_puzzle_attempt.as_json({
        only: [
          :outcome,
          :pre_user_rating,
          :post_user_rating,
          :pre_puzzle_rating,
          :post_puzzle_rating,
        ]
      }),
      user_rating: current_user.user_rating.reload.as_json({
        only: [:rated_puzzle_attempts_count]
      })
    }
  end

  private

  def user_rating
    @user_rating = current_user.user_rating || current_user.build_user_rating
  end

  def puzzle_attempt_params
    params.require(:puzzle_attempt).permit(
      :id,
      :elapsed_time_ms,
      :uci_moves => []
    )
  end
end
