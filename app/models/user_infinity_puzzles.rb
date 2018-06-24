# convenience class for figuring out which puzzles to show the user

class UserInfinityPuzzles

  def initialize(user)
    @user = user
  end

  # the next set of puzzles to show the user + config for the front-end
  #
  def next_puzzle_set(difficulty = nil, new_lichess_puzzle_id = nil)
    target_difficulty = difficulty || current_difficulty
    puzzles = new_lichess_puzzles_after(target_difficulty, new_lichess_puzzle_id)
    if puzzles.length == 0
      puzzles = [
        InfinityLevel.find_by(difficulty: target_difficulty).last_puzzle
      ]
    end
    PuzzlesJson.new(puzzles).to_json.merge({
      difficulty: target_difficulty,
      num_solved: @user ? @user.num_infinity_puzzles_solved : nil
    })
  end

  private

  def current_difficulty
    @user.present? ? @user.latest_difficulty : 'easy'
  end

  def new_lichess_puzzles_after(difficulty, new_lichess_puzzle_id)
    if @user.present?
      @user.new_lichess_puzzles_after(difficulty, new_lichess_puzzle_id)
    else
      InfinityLevel.find_by(difficulty: difficulty).new_lichess_puzzles_after(nil)
    end
  end
end
