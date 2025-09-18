# haste mode puzzles

class GameModes::HasteController < ApplicationController

  def index
    render "game_modes/haste"
  end

  # json endpoint for fetching puzzles on initial pageload
  def puzzles
    render json: {
      puzzles: HastePuzzle.random_level(100).as_json(lichess_puzzle_id: true)
    }
  end

  # player has completed a haste round
  def complete
    score = completed_haste_round_params[:score].to_i
    puzzle_ids = completed_haste_round_params[:puzzle_ids] || []
    
    Rails.logger.info "Haste round completed - Score: #{score}, Puzzle IDs: #{puzzle_ids.inspect}, User: #{user_signed_in? ? current_user.username : 'not signed in'}"
    
    if user_signed_in?
      if score > 0
        current_user.completed_haste_rounds.create!(score: score)
        # Track unique puzzles solved (fallback for any missed real-time tracking)
        Rails.logger.info "Tracking #{puzzle_ids.length} puzzle IDs for user #{current_user.username}"
        current_user.track_solved_puzzles(puzzle_ids)
      end
      best = current_user.best_haste_score(Time.zone.today)
    else
      best = score
    end
    render json: {
      score: score,
      best: best,
      high_scores: CompletedHasteRound.high_scores(24.hours.ago).filter_map do |user, score|
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

  def completed_haste_round_params
    params.require(:haste).permit(:score, puzzle_ids: [])
  end
end
