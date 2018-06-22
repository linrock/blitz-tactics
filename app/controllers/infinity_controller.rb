# infinity mode puzzles

class InfinityController < ApplicationController

  def index
  end

  # json endpoint for fetching puzzles
  def puzzles
    user_infinity_puzzles = UserInfinityPuzzles.new(current_user)
    render json: user_infinity_puzzles.next_puzzle_set(
      params[:difficulty],
      params[:puzzle_id]
    )
  end
end
