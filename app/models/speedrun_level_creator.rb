# For defining the criteria for speedrun levels

module SpeedrunLevelCreator
  LIMITS = {
    quick: 30,
    endurance: 150,
    marathon: 800,
  }

  def quick_puzzles
    NewLichessPuzzle.rating_range(0, 1300).white_to_move
      .vote_gt(1500).attempts_gt(5000).ascending_rating
  end

  def endurance_puzzles
    NewLichessPuzzle.rating_range(1300, 1800).white_to_move
      .vote_gt(1500).attempts_gt(8000)
  end

  def marathon_puzzles
    NewLichessPuzzle.rating_range(0, 1900).white_to_move
      .vote_gt(500).attempts_gt(1000)
  end

  def count_puzzle_pools
    SpeedrunLevel::NAMES.each do |name|
      puts "#{send("#{name}_puzzles").count} in #{name} pool"
    end
  end

  SpeedrunLevel::NAMES.each do |name|
    define_method "build_#{name}_level!" do
      limit = LIMITS[name.to_sym]
      raise "Invalid limit" if limit.nil?
      puts "Limit of #{limit} puzzles in #{name} speedrun level"
      num_levels_added = 0
      level = SpeedrunLevel.find_or_create_by(name: name)
      total_levels = level.speedrun_puzzles.count
      ActiveRecord::Base.logger.silence do
        send("#{name}_puzzles").ascending_rating.each do |puzzle|
          break if total_levels >= limit
          if level.add_puzzle(puzzle)
            num_levels_added += 1
            total_levels += 1
          end
        end
        true
      end
      puts "#{level.num_puzzles} total levels in #{name} speedrun level"
      puts "#{num_levels_added} levels added just now"
    end
  end

  extend self
end
