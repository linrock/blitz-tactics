# mate-in-one mode puzzles

class GameModes::MateInOneController < ApplicationController

  def index
    render "game_modes/mate_in_one"
  end

  # json endpoint for fetching puzzles on initial pageload
  def puzzles
    render json: {
      puzzles: MateInOnePuzzle.random_level(100)
    }
  end

  # player has completed a mate-in-one round
  def complete
    score = completed_mate_in_one_round_params[:score].to_i
    elapsed_time_ms = completed_mate_in_one_round_params[:elapsed_time_ms].to_i
    if user_signed_in?
      if score > 0
        current_user.completed_mate_in_one_rounds.create!(score: score, elapsed_time_ms: elapsed_time_ms)
      end
      best = current_user.best_mate_in_one_score(Time.zone.today)
    else
      best = score
    end
    render json: {
      score: score,
      best: best,
      high_scores: CompletedMateInOneRound.high_scores(24.hours.ago).filter_map do |user, score|
        next if user.nil?
        [user.username, score]
      end
    }
  end

  private

  def completed_mate_in_one_round_params
    params.require(:mate_in_one).permit(:score, :elapsed_time_ms)
  end
end
