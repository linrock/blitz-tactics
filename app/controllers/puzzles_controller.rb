class PuzzlesController < ApplicationController

  def index
    render :json => Puzzles::PUZZLES
  end

end
