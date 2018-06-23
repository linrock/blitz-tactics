# speedrun mode puzzles

class SpeedrunController < ApplicationController

  def index
  end

  # json endpoint for fetching puzzles
  def puzzles
    render json: PuzzlesJson.new(
      NewLichessPuzzle.white_to_move.limit(2)
    ).to_json
  end

  # user has completed a speedrun
  def complete
    render json: {
      elapsed_time_ms: params[:elapsed_time_ms]
    }
  end
end
