# threes mode puzzles

class GameModes::ThreeController < ApplicationController

  def index
    render "game_modes/three"
  end

  # json endpoint for fetching puzzles on initial pageload
  def puzzles
    puzzles_data = ThreePuzzle.random_level(100).as_json(lichess_puzzle_id: true) # 100 puzzles from 10 pools (10 per pool)
    
    render json: {
      puzzles: puzzles_data
    }
  end

  # player has completed a three round
  def complete
    score = completed_three_round_params[:score].to_i
    puzzle_ids = completed_three_round_params[:puzzle_ids] || []
    
    if user_signed_in?
      if score > 0
        current_user.completed_three_rounds.create!(score: score)
        # Track unique puzzles solved (fallback for any missed real-time tracking)
        current_user.track_solved_puzzles(puzzle_ids)
      end
      best = current_user.best_three_score(Time.zone.today)
    else
      best = score
    end
    render json: {
      score: score,
      best: best,
      high_scores: CompletedThreeRound.high_scores(24.hours.ago).filter_map do |user, score|
        next if user.nil?
        [user.username, score]
      end
    }
  end

  # track individual puzzle solved in real-time
  def track_puzzle
    puzzle_id = params[:puzzle_id]
    
    if user_signed_in? && puzzle_id.present?
      Rails.logger.info "Real-time tracking puzzle #{puzzle_id} for user #{current_user.username}"
      current_user.track_solved_puzzles([puzzle_id])
      render json: { success: true, puzzle_id: puzzle_id }
    else
      render json: { success: false, error: 'User not signed in or puzzle_id missing' }, status: 400
    end
  end

  private

  def completed_three_round_params
    params.require(:three).permit(:score, puzzle_ids: [])
  end
end
