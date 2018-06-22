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

  def count_puzzle_pools
    puts "#{easy_puzzles.count} in easy pool"
    puts "#{medium_puzzles.count} in medium pool"
    puts "#{hard_puzzles.count} in hard pool"
    puts "#{insane_puzzles.count} in insane pool"
  end

  InfinityLevel::DIFFICULTIES.each do |difficulty|
    define_method "build_#{difficulty}_level!" do
      num_levels_added = 0
      level = InfinityLevel.send difficulty
      ActiveRecord::Base.logger.silence do
        send("#{difficulty}_puzzles").each do |puzzle|
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
