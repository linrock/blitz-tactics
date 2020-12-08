# threes mode puzzles

class GameModes::ThreeController < ApplicationController

  def index
    render "game_modes/three"
  end

  # json endpoint for fetching puzzles on initial pageload
  def puzzles
    render json: {
      # This uses the same puzzle pool as Haste mode
      puzzles: HastePuzzle.random_level(100).as_json(lichess_puzzle_id: true)
    }
  end

  # player has completed a three round
  def complete
    score = completed_three_round_params[:score].to_i
    if user_signed_in?
      if score > 0
        current_user.completed_three_rounds.create!(score: score)
      end
      best = current_user.best_three_score(Date.today)
    else
      best = score
    end
    render json: {
      score: score,
      best: best,
      high_scores: CompletedThreeRound.high_scores(24.hours.ago).map do |user, score|
        [user.username, score]
      end
    }
  end

  private

  def completed_three_round_params
    params.require(:three).permit(:score)
  end
end
