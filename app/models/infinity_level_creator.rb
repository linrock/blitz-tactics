# For defining the criteria for puzzles to add to levels

class InfinityLevelBuilder

  def easy_puzzles
    NewLichessPuzzle.rating_lt(1000).vote_gt(50).attempts_gt(5000).white_to_move
  end

  def build_easy_level!
    level = InfinityLevel.find_or_create_by(difficulty: 'easy')
    easy_puzzles.each do |puzzle|
      level.add_puzzle puzzle.id
    end
  end
end
