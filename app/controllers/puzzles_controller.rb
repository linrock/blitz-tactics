# For viewing the puzzles in the database

class PuzzlesController < ApplicationController

  def index
    if params[:puzzle_ids]
      puzzle_ids = params[:puzzle_ids].split(',').take(100)
      @puzzles = Puzzle.find_by_sorted(puzzle_ids)
    else
      @puzzles = Puzzle.order('id DESC').limit(9)
    end
  end

  def show
    @puzzle = Puzzle.find_by_puzzle_id(params[:puzzle_id])
    if current_user
      @has_reported_puzzle = @puzzle.puzzle_reports.exists?(user_id: current_user.id)
    end
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
