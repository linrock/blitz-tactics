# For generating daily speedrun levels

module CountdownLevelCreator
  OUTFILE_NAME = -> (date) { "countdown-#{date.strftime}.json" }

  N_PUZZLES = 100  # number of puzzles per countdown level

  POOL_1 = [
    Puzzle.rating_range(1000, 1300).white_to_move.vote_gt(80),
    Puzzle.rating_range(1301, 1400).black_to_move.vote_gt(80),
    Puzzle.rating_range(1401, 1500).white_to_move.vote_gt(80),
    Puzzle.rating_range(1501, 1600).black_to_move.vote_gt(80),
    Puzzle.rating_range(1601, 1700).white_to_move.vote_gt(80),
    Puzzle.rating_range(1701, 1800).black_to_move.vote_gt(80),
    Puzzle.rating_range(1801, 1900).white_to_move.vote_gt(80),
    Puzzle.rating_range(1901, 2000).black_to_move.vote_gt(80),
    Puzzle.rating_range(2001, 2200).white_to_move.vote_gt(80),
    Puzzle.rating_gte(2201).black_to_move.vote_gt(80),
  ].map {|pool| pool.new_not_deleted.no_retry }

  POOL_2 = [
    Puzzle.rating_range(1000, 1300).black_to_move.vote_gt(80),
    Puzzle.rating_range(1301, 1400).white_to_move.vote_gt(80),
    Puzzle.rating_range(1401, 1500).black_to_move.vote_gt(80),
    Puzzle.rating_range(1501, 1600).white_to_move.vote_gt(80),
    Puzzle.rating_range(1601, 1700).black_to_move.vote_gt(80),
    Puzzle.rating_range(1701, 1800).white_to_move.vote_gt(80),
    Puzzle.rating_range(1801, 1900).black_to_move.vote_gt(80),
    Puzzle.rating_range(1901, 2000).white_to_move.vote_gt(80),
    Puzzle.rating_range(2001, 2200).black_to_move.vote_gt(80),
    Puzzle.rating_gte(2201).white_to_move.vote_gt(80),
  ].map {|pool| pool.new_not_deleted.no_retry }

  def count_pools
    ActiveRecord::Base.logger.silence do
      w_pool = POOL_1.map(&:count)
      puts "pool 1: #{w_pool} = #{w_pool.sum}"
      b_pool = POOL_2.map(&:count)
      puts "pool 2: #{b_pool} = #{b_pool.sum}"
      puts "total #: #{w_pool.sum + b_pool.sum}"
    end
  end

  def export_puzzles_for_date(date)
    puzzles = generate_puzzles(date)
    open(CountdownLevel::LEVELS_DIR.join(OUTFILE_NAME.call(date)), "w") do |f|
      f.write JSON.pretty_generate(puzzles).to_s
    end
  end

  def export_puzzles_for_date_range(from_date, to_date)
    date_range = Date.strptime(from_date)..Date.strptime(to_date)
    date_range.each do |date|
      export_puzzles_for_date(date)
    end
  end

  # seed = used for random numbers
  def puzzle_ids(seed, pool)
    n = N_PUZZLES / pool.size
    puzzle_ids = []
    pool.each do |group|
      puzzles = group.shuffle(random: Random.new(seed)).take(n)
      puzzle_ids << puzzles.map(&:id)
    end
    puzzle_ids.flatten
  end

  def generate_puzzles(date)
    pool = date.day % 2 == 0 ? POOL_1 : POOL_2
    if pool == POOL_1
      puts "Using pool 1 for #{date.to_s}"
    elsif pool == POOL_2
      puts "Using pool 2 for #{date.to_s}"
    end
    ActiveRecord::Base.logger.silence do
      ids = puzzle_ids(date.hash, pool)
      ids.map do |id|
        Puzzle.find(id).bt_puzzle_data
      end
    end
  end

  extend self
end
