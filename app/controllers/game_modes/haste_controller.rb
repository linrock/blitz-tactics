# haste mode puzzles

class GameModes::HasteController < ApplicationController

  def index
    render "game_modes/haste"
  end

  # json endpoint for fetching puzzles on initial pageload
  def puzzles
    render json: {
      puzzles: HastePuzzle.random_level(70)
    }
  end

  # user has completed a haste round
  def complete
    score = completed_haste_round_params[:score].to_i
    if user_signed_in?
      current_user.completed_haste_rounds.create!(score: score)
      render json: {
        score: score,
        best: current_user.best_haste_score(Date.today)
      }
    else
      render json: {
        score: score,
        best: score
      }
    end
  end

  private

  def completed_haste_round_params
    params.require(:haste).permit(:score)
  end
end
