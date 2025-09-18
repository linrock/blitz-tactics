# rook endgames mode puzzles

class GameModes::RookEndgamesController < ApplicationController

  def index
    render "game_modes/rook_endgames"
  end

  # json endpoint for fetching puzzles on initial pageload
  def puzzles
    render json: {
      puzzles: RookEndgamePuzzle.random_level(100)
    }
  end

  # player has completed a rook endgames round
  def complete
    score = completed_rook_endgames_round_params[:score].to_i
    elapsed_time_ms = completed_rook_endgames_round_params[:elapsed_time_ms].to_i
    
    if user_signed_in?
      if score > 0
        current_user.completed_rook_endgames_rounds.create!(
          score: score,
          elapsed_time_ms: elapsed_time_ms
        )
      end
      best = current_user.best_rook_endgames_score(Time.zone.today)
    else
      best = score
    end
    
    render json: {
      score: score,
      best: best,
      high_scores: CompletedRookEndgamesRound.high_scores(24.hours.ago).filter_map do |user, score|
        next if user.nil?
        [user.username, score]
      end
    }
  end

  private

  def completed_rook_endgames_round_params
    params.require(:rook_endgames).permit(:score, :elapsed_time_ms)
  end
end