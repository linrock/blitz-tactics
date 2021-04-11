# infinity mode puzzles

class GameModes::InfinityController < ApplicationController
  before_action :set_user

  def index
    render "game_modes/infinity"
  end

  # json endpoint for fetching puzzles
  def puzzles_json
    render json: @user.next_infinity_puzzle_set(
      params[:difficulty],
      params[:after_puzzle_id]
    )
  end

  # shows a list of puzzles you've seen recently
  def puzzles
    if current_user
      solved_puzzle_ids = @user.solved_infinity_puzzles.
        order('id DESC').limit(30).
        includes(:infinity_puzzle).
        map do |solved|
          solved.infinity_puzzle.data['id']
        end
      @puzzles = Puzzle.find_by_sorted(solved_puzzle_ids)
    else
      @puzzles = []
    end
  end

  # notifying server of status updates in infinity mode
  def puzzle_solved
    if @user.present?
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
