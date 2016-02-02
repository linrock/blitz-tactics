class PuzzlesController < ApplicationController

  def index
    render :json => Puzzles.shuffled
  end

end
