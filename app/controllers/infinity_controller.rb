# infinity mode puzzles

class InfinityController < ApplicationController
  before_action :set_user, only: :solved_puzzle

  def index
  end

  # json endpoint for fetching puzzles
  def puzzles
    user_infinity_puzzles = UserInfinityPuzzles.new(current_user)
    render json: user_infinity_puzzles.next_puzzle_set(
      params[:difficulty],
      params[:after_puzzle_id]
    )
  end

  # notifying server of status updates in infinity mode
  def puzzle_solved
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
