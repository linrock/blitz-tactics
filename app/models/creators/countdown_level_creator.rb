# For generating daily countdown levels using LevelCreator

module CountdownLevelCreator
  OUTFILE_NAME = -> (date) { "countdown-#{date.strftime}.json" }

  N_PUZZLES = 100  # number of puzzles per countdown level

  # Use the same puzzle counts as LevelCreator
  COUNTDOWN_PUZZLE_COUNTS = LevelCreator::DEFAULT_PUZZLE_COUNTS

  def count_pools
    puts "Countdown pools analysis:"
    LevelCreator.analyze_pool_sizes(COUNTDOWN_PUZZLE_COUNTS)
  end

  def export_puzzles_for_date(date)
    puzzles = generate_puzzles(date)
    FileUtils.mkdir_p(CountdownLevel::LEVELS_DIR)
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

  def generate_puzzles(date)
    # Determine color to move based on date.day % 2
    # Even days = white to move, odd days = black to move
    color_to_move = date.day % 2 == 0 ? 'w' : 'b'
    
    puts "Using #{color_to_move.upcase} to move for #{date.to_s} (day #{date.day})"
    
    # Use LevelCreator to generate puzzle IDs with the determined color
    puzzle_ids = LevelCreator.create_level_from_pools_fast(
      puzzle_counts: COUNTDOWN_PUZZLE_COUNTS,
      pools_dir: "data/puzzle-pools/",
      color_to_move: color_to_move
    )
    
    # Convert puzzle IDs to puzzle data format
    ActiveRecord::Base.logger.silence do
      puzzle_ids.map do |puzzle_id|
        puzzle = LichessV2Puzzle.find_by(puzzle_id: puzzle_id)
        if puzzle
          puzzle.bt_puzzle_data
        else
          # Fallback to old Puzzle model if not found in LichessV2Puzzle
          puzzle = Puzzle.find_by(id: puzzle_id)
          puzzle&.bt_puzzle_data
        end
      end.compact
    end
  end

  extend self
end