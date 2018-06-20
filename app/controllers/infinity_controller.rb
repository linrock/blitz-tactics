class InfinityController < ApplicationController

  def index
    user_infinity_puzzles = UserInfinityPuzzles.new(current_user)
    respond_to do |format|
      format.html {}
      format.json {
        render json: user_infinity_puzzles.next_puzzle_set(
          params[:difficulty],
          params[:puzzle_id]
        )
      }
    end
  end
end
