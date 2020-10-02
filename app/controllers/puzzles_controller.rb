# For viewing the puzzles in the database

class PuzzlesController < ApplicationController

  def index
  end

  def show
    @puzzle = Puzzle.find_by_puzzle_id(params[:puzzle_id])
  end

  def edit
    @puzzle = Puzzle.find_by_puzzle_id(parmas[:puzzle_id])
  end

  def update
  end
end