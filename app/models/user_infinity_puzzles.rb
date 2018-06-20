# convenience class for figuring out which puzzles to show the user

class UserInfinityPuzzles

  def initialize(user)
    @user = user
  end

  # the next set of puzzles to show the user + config for the front-end
  #
  def next_puzzle_set(difficulty = nil, puzzle_id = nil)
    pointer = current_iterator(difficulty, puzzle_id)
    puzzles = 10.times.map do # Array<NewLichessPuzzle>
      puzzle = pointer.puzzle
      if puzzle
        pointer = pointer.next
        puzzle
      end
    end.compact
    PuzzlesJson.new(puzzles).to_json.merge({
      difficulty: pointer.difficulty,
      num_solved: @user ? @user.num_infinity_puzzles_solved : nil
    })
  end

  # an infinity iterator at the user's current puzzle
  #
  def current_iterator(difficulty, puzzle_id) # InfinityIterator
    if @user.present?
      difficulty ||= @user.latest_difficulty
      latest = latest_infinity_iterator(difficulty)
      latest ? latest : infinity_level(difficulty).iterator_at_beginning
    else
      difficulty ||= 'easy'
      level = infinity_level(difficulty)
      puzzle_id ? level.puzzle_at(puzzle_id) : level.iterator_at_beginning
    end
  end

  # the last puzzle solved for a difficulty
  # 
  def latest_infinity_iterator(difficulty) # InfinityIterator
    completed_puzzle = @user.latest_infinity_puzzle_solved(difficulty) or nil
    return unless completed_puzzle.present?
    infinity_level(difficulty).iterator_at(completed_puzzle.puzzle_id)
  end

  private

  def infinity_level(difficulty) # InfinityLevel
    InfinityLevel.find_by(difficulty: difficulty)
  end
end
