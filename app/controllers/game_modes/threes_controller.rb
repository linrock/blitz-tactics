# threes mode puzzles

class GameModes::ThreesController < ApplicationController

  def index
    render "game_modes/threes"
  end

  # json endpoint for fetching puzzles on initial pageload
  def puzzles
    render json: {
      puzzles: ThreesPuzzle.random_level(100).as_json(lichess_puzzle_id: true)
    }
  end

  # player has completed a threes round
  def complete
    score = completed_threes_round_params[:score].to_i
    if user_signed_in?
      if score > 0
        current_user.completed_threes_rounds.create!(score: score)
      end
      best = current_user.best_threes_score(Date.today)
    else
      best = score
    end
    render json: {
      score: score,
      best: best,
      high_scores: CompletedThreesRound.high_scores(24.hours.ago).map do |user, score|
        [user.username, score]
      end
    }
  end

  private

  def completed_threes_round_params
    params.require(:threes).permit(:score)
  end
end
