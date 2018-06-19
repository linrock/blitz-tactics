class InfinityController < ApplicationController

  def index
    respond_to do |format|
      format.html {}
      format.json {
        render json: {
          format: 'lichess',
          puzzles: LichessPuzzle.limit(10).all.map(&:simplified_data)
        }
      }
    end
  end
end
