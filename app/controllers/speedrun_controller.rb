# speedrun mode puzzles

class SpeedrunController < ApplicationController

  def index
  end

  # json endpoint for fetching puzzles
  def puzzles
    render json: PuzzlesJson.new(NewLichessPuzzle.limit(10)).to_json
  end
end
