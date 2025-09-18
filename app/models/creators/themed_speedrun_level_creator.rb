# For generating themed daily speedrun levels using ThemedLevelCreator
# Selects a random theme and creates speedrun levels with 30 puzzles from that theme

module ThemedSpeedrunLevelCreator
  OUTFILE_NAME = -> (date) { "speedrun-#{date.strftime}.json" }

  N_PUZZLES = 30  # number of puzzles per speedrun level

  # Only use the first 3 pools (easiest difficulty ranges) for speedrun
  # 10 puzzles from each pool = 30 total puzzles
  THEMED_SPEEDRUN_PUZZLE_COUNTS = {
    (600..1000) => 10,  # Pool 1
    (800..1000) => 10,  # Pool 2  
    (1000..1200) => 10, # Pool 3
  }.freeze

  # Get available themes dynamically from data/themes/ directories
  def self.available_themes
    themes_dir = Rails.root.join("data/themes/")
    return [] unless Dir.exist?(themes_dir)
    
    # Get all subdirectories in data/themes/
    Dir.glob(File.join(themes_dir, "*")).select do |path|
      File.directory?(path)
    end.map do |path|
      File.basename(path)
    end.sort
  end

  # Cache available themes for performance
  def self.speedrun_themes
    @speedrun_themes ||= available_themes
  end

  def count_themed_pools(theme = nil)
    if theme
      puts "Themed speedrun pools analysis for #{theme}:"
      ThemedLevelCreator.analyze_theme_pool_sizes(
        theme: theme, 
        puzzle_counts: THEMED_SPEEDRUN_PUZZLE_COUNTS
      )
    else
      puts "Analyzing themed speedrun pools for all available themes..."
      speedrun_themes.each do |theme|
        puts "\n#{theme.capitalize}:"
        analysis = ThemedLevelCreator.analyze_theme_pool_sizes(
          theme: theme, 
          puzzle_counts: THEMED_SPEEDRUN_PUZZLE_COUNTS
        )
        %w[w b].each do |color|
          total = analysis[color].values.sum
          puts "  #{color.upcase} to move: #{total} puzzles"
        end
      end
    end
  end

  def export_puzzles_for_date(date)
    puzzle_data = generate_puzzles(date)
    FileUtils.mkdir_p(SpeedrunLevel::LEVELS_DIR)
    open(SpeedrunLevel::LEVELS_DIR.join(OUTFILE_NAME.call(date)), "w") do |f|
      f.write JSON.pretty_generate(puzzle_data).to_s
    end
  end

  def export_puzzles_for_date_range(from_date, to_date)
    (Date.strptime(from_date)..Date.strptime(to_date)).each do |date|
      export_puzzles_for_date(date)
    end
  end

  def generate_puzzles(date)
    # Select a random theme based on the date (deterministic)
    Random.srand(date.yday + date.year * 1000) # Use day of year + year as seed
    selected_theme = speedrun_themes.sample
    
    # Determine color to move based on date.day % 2
    # Even days = white to move, odd days = black to move
    color_to_move = date.day % 2 == 0 ? 'w' : 'b'
    
    puts "Creating themed speedrun for #{date.to_s}"
    puts "Selected theme: #{selected_theme}"
    puts "Color to move: #{color_to_move.upcase} (day #{date.day})"
    
    # Create puzzles using themed pools
    puzzle_ids = create_themed_speedrun_level_from_pools(
      theme: selected_theme,
      puzzle_counts: THEMED_SPEEDRUN_PUZZLE_COUNTS,
      pools_dir: "data/themes/",
      color_to_move: color_to_move
    )
    
    # Convert puzzle IDs to puzzle data format
    puzzles = ActiveRecord::Base.logger.silence do
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
    
    # Return new themed format
    {
      theme: selected_theme,
      puzzles: puzzles
    }
  end

  # Create themed speedrun level from theme pools
  def create_themed_speedrun_level_from_pools(theme:, puzzle_counts:, pools_dir:, color_to_move:)
    unless ThemedLevelCreator::VALID_THEMES.include?(theme)
      raise ArgumentError, "Invalid theme '#{theme}'. Valid themes: #{ThemedLevelCreator::VALID_THEMES.join(', ')}"
    end

    selected_puzzle_ids = []
    theme_pools_dir = Rails.root.join(pools_dir, theme)
    
    unless Dir.exist?(theme_pools_dir)
      puts "Warning: Theme directory #{theme_pools_dir} does not exist"
      puts "Available themes: #{Dir.glob(Rails.root.join(pools_dir, '*')).map { |d| File.basename(d) }.join(', ')}"
      return []
    end
    
    puzzle_counts.each_with_index do |(rating_range, sample_count), index|
      pool_number = index + 1
      padded_pool_number = format("%02d", pool_number)
      filename = "#{color_to_move}_pool_#{padded_pool_number}_#{rating_range.min}-#{rating_range.max}.txt"
      file_path = Rails.root.join(theme_pools_dir, filename)
      
      if File.exist?(file_path)
        pool_puzzle_data = File.readlines(file_path).map(&:strip).reject(&:empty?)
        if pool_puzzle_data.any?
          puts "  Pool #{pool_number} (#{rating_range}): #{pool_puzzle_data.length} available, sampling #{sample_count}"
          
          # Simple random sampling for speedrun (no complex theme variety needed)
          sampled_lines = pool_puzzle_data.sample(sample_count)
          
          # Extract puzzle IDs
          sampled_lines.each do |line|
            puzzle_id = line.split("|", 3)[0] # Just get the puzzle_id
            selected_puzzle_ids << puzzle_id
          end
        else
          puts "  Pool #{pool_number} (#{rating_range}): No puzzles available"
        end
      else
        puts "  Pool #{pool_number} (#{rating_range}): File not found - #{file_path}"
      end
    end
    
    puts "  Total puzzles selected: #{selected_puzzle_ids.length}"
    selected_puzzle_ids
  end

  # Get a random theme for manual testing
  def random_theme
    speedrun_themes.sample
  end

  # Generate puzzles for a specific theme (for testing)
  def generate_puzzles_for_theme(date, theme)
    unless speedrun_themes.include?(theme)
      raise ArgumentError, "Theme '#{theme}' not available for speedrun. Available: #{speedrun_themes.join(', ')}"
    end

    # Determine color to move based on date.day % 2
    color_to_move = date.day % 2 == 0 ? 'w' : 'b'
    
    puts "Creating themed speedrun for #{date.to_s}"
    puts "Selected theme: #{theme}"
    puts "Color to move: #{color_to_move.upcase} (day #{date.day})"
    
    # Create puzzles using themed pools
    puzzle_ids = create_themed_speedrun_level_from_pools(
      theme: theme,
      puzzle_counts: THEMED_SPEEDRUN_PUZZLE_COUNTS,
      pools_dir: "data/themes/",
      color_to_move: color_to_move
    )
    
    # Convert puzzle IDs to puzzle data format
    puzzles = ActiveRecord::Base.logger.silence do
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
    
    # Return new themed format
    {
      theme: theme,
      puzzles: puzzles
    }
  end

  extend self
end
