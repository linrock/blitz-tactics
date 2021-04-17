class PuzzleSetsController < ApplicationController

  def index
    @puzzle_sets = PuzzleSet.all.limit(20)
  end

  def show
  end

  def new
    @new_puzzle_set = PuzzleSet.new(user_id: current_user.id)
  end

  def create
    puzzle_set_params = params.require(:puzzle_set).permit(:name, :description, :puzzle_ids)
    LichessV2Puzzle.all.limit(10).pluck(:puzzle_id)
    current_user.puzzle_sets.create!(puzzle_set_params.merge({
      puzzle_ids: puzzle_set_params[:puzzle_ids]
    }))
  end

  def update
  end
end