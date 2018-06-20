class InfinityController < ApplicationController

  def index
    if current_user
      if params[:difficulty]
        difficulty = params[:difficulty]
        infinity_level = InfinityLevel.find_by(difficulty: difficulty)
        puzzles = infinity_level.next_n_puzzles_from(nil, 10)
        # TODO look up user's difficulty
      else
        difficulty = current_user.latest_difficulty
        infinity_level = current_user.latest_infinity_level
        next_puzzle_id = current_user.next_infinity_puzzle.puzzle_id
        puzzles = infinity_level.next_n_puzzles_from(next_puzzle_id, 10)
      end
      # puzzles = infinity_level.next_n_puzzles_from(nil, 10)
      config = {
        difficulty: difficulty,
        num_solved: current_user.infinity_puzzles_solved
      }
    else
      difficulty = params[:difficulty] || 'easy'
      infinity_level = InfinityLevel.find_by(difficulty: difficulty)
      puzzles = infinity_level.next_n_puzzles_from(nil, 10)
      config = {
        difficulty: difficulty,
        num_solved: 0,
      }
    end
    respond_to do |format|
      format.html {}
      format.json {
        render json: PuzzlesJson.new(puzzles).to_json.merge(config)
      }
    end
  end
end
