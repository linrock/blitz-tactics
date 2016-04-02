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
    @puzzles = LichessPuzzle.rating_lt(1400).white_to_move
    if params[:pieces].present?
      @puzzles = @puzzles.n_pieces_eq(params[:pieces])
    end
    @n_puzzles = @puzzles.count
    @puzzles = @puzzles.limit(100)
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
