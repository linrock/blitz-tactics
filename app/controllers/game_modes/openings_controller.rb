# openings mode puzzles

class GameModes::OpeningsController < ApplicationController

  def index
    render "game_modes/openings"
  end

  # json endpoint for fetching puzzles on initial pageload
  def puzzles
    render json: {
      puzzles: OpeningPuzzle.random_level(100)
    }
  end

  # player has completed an openings round
  def complete
    score = completed_openings_round_params[:score].to_i
    elapsed_time_ms = completed_openings_round_params[:elapsed_time_ms].to_i
    
    if user_signed_in?
      if score > 0
        current_user.completed_openings_rounds.create!(
          score: score,
          elapsed_time_ms: elapsed_time_ms
        )
      end
      best = current_user.best_openings_score(Time.zone.today)
    else
      best = score
    end
    
    render json: {
      score: score,
      best: best,
      high_scores: CompletedOpeningsRound.high_scores(24.hours.ago).filter_map do |user, score|
        next if user.nil?
        [user.username, score]
      end
    }
  end

  private

  def completed_openings_round_params
    params.require(:openings).permit(:score, :elapsed_time_ms)
  end
end
