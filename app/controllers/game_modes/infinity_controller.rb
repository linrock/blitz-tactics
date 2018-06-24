# infinity mode puzzles

class GameModes::InfinityController < ApplicationController
  before_action :set_user, only: :puzzle_solved

  def index
    render "game_modes/infinity"
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
      solved_puzzle = @user.solved_infinity_puzzles.find_by(
        solved_puzzle_params
      )
      if solved_puzzle.present?
        solved_puzzle.touch
      else
        @user.solved_infinity_puzzles.create!(solved_puzzle_params)
      end
      render json: { n: @user.solved_infinity_puzzles.count }
    else
      render json: {}
    end
  end

  private

  def solved_puzzle_params
    p_params = params.require(:puzzle).permit(:difficulty, :puzzle_id).to_h
    p_params["infinity_puzzle_id"] = p_params["puzzle_id"]
    p_params.delete("puzzle_id")
    p_params
  end
end
