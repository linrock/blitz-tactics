class PuzzlesController < ApplicationController

  N_PUZZLES = 25


  def index
    @n_sets = 50
  end

  def show
    render_v1
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
        :n      => N_PUZZLES,
        :offset => params[:offset].to_i,
        :turn   => 'w'
      }).shuffle
    }
  end

end
