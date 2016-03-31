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

  def search
    @puzzles = LichessPuzzle.rating_lt(1400).white_to_move.limit(100)
    respond_to do |format|
      format.html {}
      format.json {
        render :json => {
          :format  => 'lichess',
          :puzzles => @puzzles.map(&:data)
        }
      }
    end
  end

end
