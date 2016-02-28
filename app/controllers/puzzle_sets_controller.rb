class PuzzleSetsController < ApplicationController

  def index
    @n_sets = 50
  end

  def show
    # render_v1
    render_lichess
  end

  private

  def render_v0
    render :json => {
      :format  => 'v0',
      :puzzles => Puzzles.shuffled
    }
  end

  def render_v1
    render :json => {
      :format  => 'v1',
      :puzzles => TacticsLoader.query({
        :n      => Puzzles::SET_SIZE,
        :offset => params[:offset].to_i,
        :turn   => 'w'
      }).shuffle
    }
  end

  def render_lichess
    puzzles = LichessPuzzle.rating_lt(1500).
                            vote_gt(100).
                            white_to_move
    offset = params[:offset].to_i
    render :json => {
      :format  => 'lichess',
      :puzzles => puzzles[offset..offset + Puzzles::SET_SIZE].shuffle.map(&:data)
    }
  end

end
