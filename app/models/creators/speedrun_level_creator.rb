# For generating daily speedrun levels using LevelCreator

module SpeedrunLevelCreator
  OUTFILE_NAME = -> (date) { "speedrun-#{date.strftime}.json" }

  N_PUZZLES = 30  # number of puzzles per speedrun level

  # Speedrun-specific puzzle counts - relatively easy puzzles
  SPEEDRUN_PUZZLE_COUNTS = {
    (600..800) => 5,
    (800..1000) => 5,
    (1000..1200) => 10,
    (1200..1400) => 10,
  }.freeze

  def count_pools
    puts "Speedrun pools analysis:"
    LevelCreator.analyze_pool_sizes(SPEEDRUN_PUZZLE_COUNTS)
  end

  def export_puzzles_for_date(date)
    puzzles = generate_puzzles(date)
    FileUtils.mkdir_p(SpeedrunLevel::LEVELS_DIR)
    open(SpeedrunLevel::LEVELS_DIR.join(OUTFILE_NAME.call(date)), "w") do |f|
      f.write JSON.pretty_generate(puzzles).to_s
    end
  end

  def export_puzzles_for_date_range(from_date, to_date)
    (Date.strptime(from_date)..Date.strptime(to_date)).each do |date|
      export_puzzles_for_date(date)
    end
  end

  def generate_puzzles(date)
    # Determine color to move based on date.day % 2
    # Even days = white to move, odd days = black to move
    color_to_move = date.day % 2 == 0 ? 'w' : 'b'
    
    puts "Using #{color_to_move.upcase} to move for #{date.to_s} (day #{date.day})"
    
    # Use LevelCreator with checkmate and fork limiting
    puzzle_ids = create_speedrun_level_from_pools(
      puzzle_counts: SPEEDRUN_PUZZLE_COUNTS,
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

  # Custom level creation with both checkmate and fork limiting
  def create_speedrun_level_from_pools(puzzle_counts:, pools_dir:, color_to_move:)
    selected_puzzle_ids = []
    
    puzzle_counts.each_with_index do |(rating_range, sample_count), index|
      pool_number = index + 1
      padded_pool_number = format("%02d", pool_number)
      filename = "#{color_to_move}_pool_#{padded_pool_number}_#{rating_range.min}-#{rating_range.max}.txt"
      file_path = Rails.root.join(pools_dir, filename)
      
      if File.exist?(file_path)
        pool_puzzle_data = File.readlines(file_path).map(&:strip).reject(&:empty?)
        if pool_puzzle_data.any?
          # FAST: Simple random sampling with checkmate and fork limiting
          max_checkmates = (sample_count * 0.33).floor
          max_forks = (sample_count * 0.33).floor
          checkmate_count = 0
          fork_count = 0
          sampled_lines = []
          
          # Shuffle and sample with theme limiting
          pool_puzzle_data.shuffle.each do |line|
            break if sampled_lines.length >= sample_count
            
            parts = line.split("|", 3)
            if parts.length == 3
              themes_str = parts[2] || ""
              is_checkmate = themes_str.include?("mate")
              is_fork = themes_str.include?("fork")
              
              # Check constraints
              checkmate_ok = !is_checkmate || checkmate_count < max_checkmates
              fork_ok = !is_fork || fork_count < max_forks
              
              # Add if constraints are satisfied
              if checkmate_ok && fork_ok
                sampled_lines << line
                checkmate_count += 1 if is_checkmate
                fork_count += 1 if is_fork
              end
            else
              # If we can't parse themes, add it (assume it's safe)
              sampled_lines << line if sampled_lines.length < sample_count
            end
          end
          
          # Extract puzzle IDs
          sampled_lines.each do |line|
            puzzle_id = line.split("|", 3)[0] # Just get the puzzle_id
            selected_puzzle_ids << puzzle_id
          end
        end
      end
    end
    
    selected_puzzle_ids
  end

  extend self
end
