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
    # Lichess v2 puzzle IDs are alphanumeric strings of length 5
    filtered_puzzle_ids = puzzle_set_params[:puzzle_ids].
      gsub(/[^a-zA-Z0-9]/, ' ').strip.split(/\s+/).
      select {|puzzle_id| puzzle_id.length == 5 }
    lichess_v2_puzzles = LichessV2Puzzle.where(puzzle_id: filtered_puzzle_ids)
    if lichess_v2_puzzles.count > 0
      puzzle_set = current_user.puzzle_sets.create!({
        name: puzzle_set_params[:name],
        description: puzzle_set_params[:description]
      })
      puzzle_set.lichess_v2_puzzles = lichess_v2_puzzles
    else
      # No valid puzzle IDs found in the payload. Do nothing.
    end
  end

  def update
  end
end