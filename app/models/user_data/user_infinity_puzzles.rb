# convenience class for figuring out which infinity puzzles to show the user

class UserInfinityPuzzles

  def initialize(user)
    @user = user # User or NilUser
  end

  # the next set of puzzles to show the user + config for the front-end
  def next_infinity_puzzle_set(difficulty = nil, puzzle_id = nil)
    target_difficulty = difficulty || current_difficulty
    puzzles = infinity_puzzles_after(target_difficulty, puzzle_id)
    if puzzles.length == 0 and puzzle_id.nil?
      # if user starts on the last puzzle
      puzzles = [infinity_level(target_difficulty).last_puzzle]
    end
    {
      puzzles: puzzles,
      difficulty: target_difficulty,
      num_solved: @user.present? ? @user.num_infinity_puzzles_solved : nil
    }
  end

  # used on the homepage to decide the next puzzle to show
  def next_infinity_puzzle
    if @user.present?
      infinity_puzzles_after(
        latest_difficulty,
        last_solved_infinity_puzzle_id(latest_difficulty)
      ).first
    else
      InfinityLevel.easy.first_puzzle
    end
  end

  private

  def infinity_level(difficulty)
    if difficulty.nil?
      InfinityLevel.easy
    else
      InfinityLevel.find_by(difficulty: difficulty)
    end
  end

  def latest_difficulty
    if @user.present?
      @user.solved_infinity_puzzles.most_recent_last.last&.difficulty || 'easy'
    else
      'easy'
    end
  end

  def current_difficulty
    @user.present? ? latest_difficulty : 'easy'
  end

  def last_solved_infinity_puzzle_id(difficulty)
    if @user.present?
      # last solved infinity puzzle for logged-in users
      @user.solved_infinity_puzzles
        .with_difficulty(difficulty).most_recent_last.last&.infinity_puzzle_id
    else
      # random sample of puzzle set for anonymous users
      infinity_level(difficulty).random_puzzle_id
    end
  end

  def infinity_puzzles_after(difficulty, puzzle_id)
    target_puzzle_id = puzzle_id || last_solved_infinity_puzzle_id(difficulty)
    infinity_level(difficulty).puzzles_after_id(target_puzzle_id)
  end
end
