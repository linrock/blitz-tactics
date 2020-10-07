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
    if user_signed_in?
      if score > 0
        current_user.completed_haste_rounds.create!(score: score)
      end
      best = current_user.best_haste_score(Date.today)
    else
      best = score
    end
    render json: {
      score: score,
      best: best,
      high_scores: CompletedHasteRound.high_scores(24.hours.ago).map do |user, score|
        [user.username, score]
      end
    }
  end

  private

  def completed_haste_round_params
    params.require(:haste).permit(:score)
  end
end
