# For defining the criteria for puzzles to add to levels and building them

module InfinityLevelCreator

  def easy_puzzles
    NewLichessPuzzle.rating_range(0, 1500).white_to_move
      .vote_gt(100).attempts_gt(1000)
  end

  def medium_puzzles
    NewLichessPuzzle.rating_range(1500, 1750).white_to_move
      .vote_gt(100).attempts_gt(4000)
  end

  def hard_puzzles
    NewLichessPuzzle.rating_range(1750, 2000).white_to_move
      .vote_gt(100).attempts_gt(4000)
  end

  def insane_puzzles
    NewLichessPuzzle.rating_gt(2000).white_to_move
      .vote_gt(70).attempts_gt(700)
  end

  def count_puzzle_pools
    InfinityLevel::DIFFICULTIES.each do |difficulty|
      puts "#{send("#{difficulty}_puzzles").count} in #{difficulty} pool"
    end
  end

  InfinityLevel::DIFFICULTIES.each do |difficulty|
    define_method "build_#{difficulty}_level!" do
      num_levels_added = 0
      level = InfinityLevel.send difficulty
      ActiveRecord::Base.logger.silence do
        send("#{difficulty}_puzzles").ascending_rating.each do |puzzle|
          if level.add_puzzle(puzzle)
            num_levels_added += 1
          end
        end
        true
      end
      puts "#{level.num_puzzles} total levels in #{difficulty} difficulty"
      puts "#{num_levels_added} levels added just now"
    end
  end

  extend self
end
