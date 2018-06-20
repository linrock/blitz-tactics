# levels in infinity mode

class Api::InfinityController < ApplicationController
  before_action :set_user

  def solved_puzzle
    if @user
      @user.completed_infinity_puzzles.find_or_create_by(puzzle_params)
      render json: {
        n: @user.completed_infinity_puzzles.count
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
