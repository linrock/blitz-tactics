class PuzzlesController < ApplicationController

  def index
    puzzles = []
    AuerswaldLoader.new.puzzles.each do |puzzle|
      next unless puzzle.turn == 'w'
      puzzles << puzzle.to_h
      break if puzzles.length >= 50
    end
    # render :json => Puzzles.shuffled
    render :json => {
      :format  => 'v1',
      :puzzles => puzzles
    }
  end

end
