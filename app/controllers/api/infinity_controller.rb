# levels in infinity mode

class Api::InfinityController < ApplicationController
  before_action :set_user

  def solved_puzzle
    if @user
      puzzle = @user.solved_infinity_puzzles.find_by(puzzle_params)
      if puzzle.present?
        puzzle.touch
      else
        @user.solved_infinity_puzzles.create!(puzzle_params)
      end
      render json: { n: @user.solved_infinity_puzzles.count }
    else
      render json: {}
    end
  end

  private

  def puzzle_params
    p_params = params.require(:puzzle).permit(:difficulty, :puzzle_id).to_h
    p_params["new_lichess_puzzle_id"] = p_params["puzzle_id"]
    p_params.delete("puzzle_id")
    p_params
  end
end
