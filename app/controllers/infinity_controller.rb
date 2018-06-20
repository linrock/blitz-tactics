class InfinityController < ApplicationController

  def index
    infinity_level = InfinityLevel.find_by(difficulty: 'easy')
    inf_puzzle = infinity_level.first_puzzle
    puzzles = 10.times.map do
      puzzle = inf_puzzle.puzzle
      inf_puzzle = inf_puzzle.next_puzzle
      puzzle
    end
    respond_to do |format|
      format.html {}
      format.json {
        render json: PuzzlesJson.new(puzzles).to_json
      }
    end
  end
end
