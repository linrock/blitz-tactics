class InfinityController < ApplicationController

  def index
    infinity_level = InfinityLevel.find_by(difficulty: 'easy')
    puzzle_enumerator = infinity_level.first_puzzle
    puzzles = [puzzle_enumerator.puzzle]
    10.times do
      puzzles << puzzle_enumerator.next_puzzle.puzzle
    end
    respond_to do |format|
      format.html {}
      format.json {
        render json: {
          format: 'lichess',
          puzzles: puzzles.map(&:simplified_data)
        }
      }
    end
  end
end
