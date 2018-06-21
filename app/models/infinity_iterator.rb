class InfinityIterator

  attr_reader :difficulty, :puzzle_id

  def initialize(difficulty, puzzle_id)
    @difficulty = difficulty
    @puzzle_id = puzzle_id
  end

  def n_puzzles(n) # Array<NewLichessPuzzle>
    iterator = self
    n.times.map do
      puzzle = iterator.puzzle if !iterator.nil?
      if puzzle
        iterator = iterator.next
        puzzle
      end
    end.compact
  end

  def puzzle # NewLichessPuzzle
    NewLichessPuzzle.find_by(id: @puzzle_id)
  end

  def prev # InfinityIterator
    prev_puzzle_id = infinity_level.prev_puzzle_id(@puzzle_id)
    return if prev_puzzle_id.nil?
    InfinityIterator.new(@difficulty, prev_puzzle_id)
  end

  def next # InfinityIterator
    next_puzzle_id = infinity_level.next_puzzle_id(@puzzle_id)
    return if next_puzzle_id.nil?
    InfinityIterator.new(@difficulty, next_puzzle_id)
  end

  private

  def infinity_level # InfinityLevel
    @infinity_level ||= InfinityLevel.find_by(difficulty: @difficulty)
  end
end
