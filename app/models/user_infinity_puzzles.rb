# convenience class for figuring out which puzzles to show the user

class UserInfinityPuzzles

  def initialize(user)
    @user = user
  end

  # the next set of puzzles to show the user + config for the front-end
  #
  def next_puzzle_set(difficulty = nil, puzzle_id = nil)
    target_difficulty = difficulty || current_difficulty
    puzzles = infinity_puzzles_after(target_difficulty, puzzle_id)
    {
      puzzles: puzzles,
      difficulty: target_difficulty,
      num_solved: @user ? @user.num_infinity_puzzles_solved : nil
    }
  end

  private

  def infinity_level(difficulty)
    InfinityLevel.find_by(difficulty: difficulty)
  end

  def current_difficulty
    @user.present? ? @user.latest_difficulty : 'easy'
  end

  def infinity_puzzles_after(difficulty, puzzle_id)
    if @user.present?
      @user.infinity_puzzles_after(difficulty, puzzle_id)
    else
      infinity_level(difficulty).puzzles_after_id(puzzle_id)
    end
  end
end
