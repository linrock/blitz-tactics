# rated mode puzzles

class GameModes::RatedController < ApplicationController

  def index
    render "game_modes/rated"
  end

  # json endpoint for fetching puzzles on initial pageload
  def puzzles
    render json: {
      puzzles: RatedPuzzle.all.limit(100)
    }
  end

  # user has attempted a rated puzzle
  def attempt
  end

  private

  def puzzle_attempt_params
    params.require(:puzzle_attempt).permit(:id, :uci_moves)
  end
end
