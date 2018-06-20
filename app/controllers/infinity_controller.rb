class InfinityController < ApplicationController

  def index
    difficulty = params[:difficulty] || 'easy'
    infinity_level = InfinityLevel.find_by(difficulty: difficulty)
    puzzles = infinity_level.next_n_puzzles_from(nil, 10)
    respond_to do |format|
      format.html {}
      format.json {
        render json: PuzzlesJson.new(puzzles).to_json
      }
    end
  end
end
