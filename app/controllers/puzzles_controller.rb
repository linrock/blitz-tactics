class PuzzlesController < ApplicationController

  def show
    @puzzle = LichessPuzzle.find(params[:id])
    respond_to do |format|
      format.html {}
      format.json {
        render :json => {
          :format  => 'lichess',
          :puzzles => [@puzzle.simplified_data]
        }
      }
    end
  end

  def search
    @puzzles = LichessPuzzle.rating_lt(1400).white_to_move
    @puzzles = @puzzles.n_pieces_eq(params[:pieces]) if params[:pieces].present?
    @puzzles = @puzzles.rating_lt(params[:max_rating]) if params[:max_rating].present?
    @puzzles = @puzzles.attempts_gt(params[:min_attempts]) if params[:min_attempts].present?
    @puzzles = @puzzles.vote_gt(params[:min_votes]) if params[:min_votes].present?
    @n_puzzles = @puzzles.count
    @puzzles = @puzzles.page(params[:page]).per(100)
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
