class PuzzlesController < ApplicationController

  def index
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
        :n      => 25,
        :offset => 100,
        :turn   => 'w'
      }).shuffle
    }
  end

end
