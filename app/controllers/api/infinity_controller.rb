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
      render json: {
        n: @user.solved_infinity_puzzles.count
      }
    else
      render json: {}
    end
  end

  private

  def puzzle_params
    params.require(:puzzle).permit(:difficulty, :puzzle_id)
  end

  def set_user
    @user = current_user
  end
end
