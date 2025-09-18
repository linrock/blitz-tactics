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
    # For now, just return the score without saving to database
    # TODO: Add database tracking later if needed
    render json: {
      score: score,
      best: score,
      high_scores: []
    }
  end

  private

  def completed_rook_endgames_round_params
    params.require(:rook_endgames).permit(:score)
  end
end