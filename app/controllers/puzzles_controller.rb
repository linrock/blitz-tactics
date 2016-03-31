class PuzzlesController < ApplicationController

  def show
    @puzzle = LichessPuzzle.find(params[:id])
    respond_to do |format|
      format.html {}
      format.json {
        render :json => {
          :format  => 'lichess',
          :puzzles => [@puzzle.data]
        }
      }
    end
  end

end
