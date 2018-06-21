# For defining the criteria for puzzles to add to levels and building them

module InfinityLevelCreator

  def easy_puzzles
    NewLichessPuzzle.rating_lte(1000)
      .vote_gt(50).attempts_gt(5000).white_to_move
  end

  def medium_puzzles
    NewLichessPuzzle.rating_gt(1000).rating_lte(1600)
      .vote_gt(50).attempts_gt(5000).white_to_move
  end

  def hard_puzzles
    NewLichessPuzzle.rating_gt(1600).rating_lte(2000)
      .vote_gt(50).attempts_gt(5000).white_to_move
  end

  def insane_puzzles
    NewLichessPuzzle.rating_gt(2000)
      .vote_gt(50).attempts_gt(5000).white_to_move
  end

  InfinityLevel::DIFFICULTIES.each do |difficulty|
    define_method "build_#{difficulty}_level!" do
      level = InfinityLevel.send difficulty
      send("#{difficulty}_puzzles").each do |puzzle|
        level.add_puzzle puzzle
      end
      true
    end
  end

  extend self
end
