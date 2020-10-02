# For viewing the puzzles in the database

class PuzzlesController < ApplicationController

  def index
    @puzzles = Puzzle.order('id DESC').limit(9)
  end

  def show
    @puzzle = Puzzle.find_by_puzzle_id(params[:puzzle_id])
    unless @puzzle
      render "not_found" and return
    end
  end

  def edit
    @puzzle = Puzzle.find_by_puzzle_id(parmas[:puzzle_id])
  end

  def update
  end
end
