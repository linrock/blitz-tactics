class InfinityPuzzle

  attr_reader :difficulty, :puzzle_id

  def initialize(difficulty, puzzle_id)
    @difficulty = difficulty
    @puzzle_id = puzzle_id
  end

  def puzzle
    NewLichessPuzzle.find_by(id: @puzzle_id)
  end

  def prev_puzzle
    prev_puzzle_id = infinity_level.prev_puzzle_id(@puzzle_id)
    return if prev_puzzle_id.nil?
    InfinityPuzzle.new(@difficulty, prev_puzzle_id)
  end

  def next_puzzle
    next_puzzle_id = infinity_level.next_puzzle_id(@puzzle_id)
    return if next_puzzle_id.nil?
    InfinityPuzzle.new(@difficulty, next_puzzle_id)
  end

  private

  def infinity_level
    @infinity_level ||= InfinityLevel.find_by(difficulty: @difficulty)
  end
end
