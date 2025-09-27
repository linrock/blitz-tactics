# AdventureLevelCreator - Generates adventure mode levels with increasing difficulty
#
# Each level consists of multiple puzzle sets with progressively harder puzzles.
# Levels get more complex as the level number increases.
#
# Usage Examples:
#   # Generate a specific level
#   AdventureLevelCreator.generate_level(1)
#   AdventureLevelCreator.generate_level(10)
#
#   # Export all levels to files
#   AdventureLevelCreator.export_all_levels("data/game-modes/adventure/")
#
#   # Analyze available puzzles for each level
#   analysis = AdventureLevelCreator.analyze_level_availability
#
# Rake Tasks:
#   rake adventure:generate_level[1]                    # Generate level 1
#   rake adventure:export_all[data/game-modes/adventure/] # Export all levels
#   rake adventure:analyze                              # Analyze puzzle availability

class AdventureLevelCreator
  # Level configuration - defines difficulty progression with challenge conditions
  LEVEL_CONFIG = {
    1 => {
      description: "Beginner's Journey",
      rating_range: (600..1000),
      puzzle_sets: [
        { puzzles: 10, challenge: "solve", description: "Solve 10 puzzles" },
        { puzzles: 10, challenge: "solve", description: "Solve 10 puzzles" },
        { puzzles: 10, challenge: "without_mistakes", description: "Solve 10 puzzles without mistakes" }
      ]
    },
    2 => {
      description: "Building Foundations",
      rating_range: (700..1100),
      puzzle_sets: [
        { puzzles: 10, challenge: "solve", description: "Solve 12 puzzles" },
        { puzzles: 10, challenge: "solve", description: "Solve 12 puzzles" },
        { puzzles: 10, challenge: "without_mistakes", description: "Solve 12 puzzles without mistakes" }
      ]
    },
    3 => {
      description: "Growing Confidence",
      rating_range: (800..1200),
      puzzle_sets: [
        { puzzles: 15, challenge: "solve", description: "Solve 15 puzzles" },
        { puzzles: 15, challenge: "solve", description: "Solve 15 puzzles" },
        { puzzles: 15, challenge: "without_mistakes", description: "Solve 15 puzzles without mistakes" }
      ]
    },
    4 => {
      description: "Stepping Up",
      rating_range: (900..1300),
      puzzle_sets: [
        { puzzles: 10, challenge: "solve", description: "Solve 10 puzzles" },
        { puzzles: 10, challenge: "solve", description: "Solve 10 puzzles" },
        { puzzles: 10, challenge: "without_mistakes", description: "Solve 10 puzzles without mistakes" }
      ]
    },
    5 => {
      description: "Intermediate Challenge",
      rating_range: (1000..1400),
      puzzle_sets: [
        { puzzles: 12, challenge: "solve", description: "Solve 12 puzzles" },
        { puzzles: 10, challenge: "perfect", description: "Solve 10 puzzles perfectly (no mistakes)" },
        { puzzles: 10, challenge: "speed", description: "Solve 10 puzzles in 60 seconds" }
      ]
    },
    6 => {
      description: "Advanced Tactics",
      rating_range: (1100..1500),
      puzzle_sets: [
        { puzzles: 10, challenge: "solve", description: "Solve 10 puzzles" },
        { puzzles: 10, challenge: "solve", description: "Solve 10 puzzles" },
        { puzzles: 30, challenge: "move_combo", description: "Reach move combo 30", combo_target: 30 }
      ]
    },
    7 => {
      description: "Master's Path",
      rating_range: (1200..1600),
      puzzle_sets: [
        { puzzles: 12, challenge: "solve", description: "Solve 12 puzzles" },
        { puzzles: 10, challenge: "perfect", description: "Solve 10 puzzles perfectly (no mistakes)" },
        { puzzles: 10, challenge: "speed", description: "Solve 10 puzzles in 60 seconds" }
      ]
    },
    8 => {
      description: "Expert Territory",
      rating_range: (1300..1700),
      puzzle_sets: [
        { puzzles: 10, challenge: "solve", description: "Solve 10 puzzles" },
        { puzzles: 10, challenge: "solve", description: "Solve 10 puzzles" },
        { puzzles: 10, challenge: "solve", description: "Solve 10 puzzles" }
      ]
    },
    9 => {
      description: "Elite Challenges",
      rating_range: (1400..1800),
      puzzle_sets: [
        { puzzles: 12, challenge: "perfect", description: "Solve 12 puzzles perfectly (no mistakes)" },
        { puzzles: 10, challenge: "speed", description: "Solve 10 puzzles in 60 seconds" },
        { puzzles: 12, challenge: "perfect", description: "Solve 12 puzzles perfectly (no mistakes)" }
      ]
    },
    10 => {
      description: "Grandmaster Quest",
      rating_range: (1500..1900),
      puzzle_sets: [
        { puzzles: 10, challenge: "solve", description: "Solve 10 puzzles" },
        { puzzles: 20, challenge: "solve", description: "Solve 20 puzzles" },
        { puzzles: 20, challenge: "solve", description: "Solve 20 puzzles" }
      ]
    }
  }.freeze

  # Challenge type configurations
  CHALLENGE_CONFIGS = {
    'solve' => {
      name: 'Solve',
      description: 'Complete puzzles with mistakes allowed',
      requires_perfect: false,
      time_limit: nil
    },
    'perfect' => {
      name: 'Perfect',
      description: 'Complete puzzles without any mistakes',
      requires_perfect: true,
      time_limit: nil
    },
    'without_mistakes' => {
      name: 'Without Mistakes',
      description: 'Solve puzzles in a row without making any mistakes',
      requires_perfect: true,
      time_limit: nil,
      resets_on_mistake: true
    },
    'speed' => {
      name: 'Speed',
      description: 'Complete puzzles within time limit',
      requires_perfect: false,
      time_limit: 60, # seconds
      resets_on_mistake: false
    },
    'move_combo' => {
      name: 'Move Combo',
      description: 'Reach a move combo without letting it drop',
      requires_perfect: false,
      time_limit: nil,
      resets_on_mistake: false,
      combo_target: 30, # default combo target
      combo_drop_time: nil # default: no timer (combo only drops on mistakes)
      # To enable timer: combo_drop_time: 15 (combo drops after 15 seconds of inactivity)
    }
  }.freeze

  # Get challenge configuration for a specific challenge type
  def self.get_challenge_config(challenge_type)
    CHALLENGE_CONFIGS[challenge_type] || CHALLENGE_CONFIGS['solve']
  end

  # Generate a specific adventure level
  def self.generate_level(level_number)
    config = LEVEL_CONFIG[level_number]
    raise ArgumentError, "Level #{level_number} not defined" unless config

    puts "Generating Adventure Level #{level_number}: #{config[:description]}"
    puts "Rating range: #{config[:rating_range]}"
    puts "Puzzle sets: #{config[:puzzle_sets].length}"

    level_data = {
      level: level_number,
      description: config[:description],
      rating_range: config[:rating_range],
      puzzle_sets: []
    }

    # Generate puzzle sets for this level, alternating between white and black to move
    config[:puzzle_sets].each_with_index do |set_config, set_index|
      # Alternate between white and black to move
      color_to_move = set_index.even? ? 'w' : 'b'

      puzzle_set = generate_puzzle_set(
        level: level_number,
        set_index: set_index + 1,
        puzzles_count: set_config[:puzzles],
        rating_range: config[:rating_range],
        color_to_move: color_to_move,
        challenge: set_config[:challenge],
        challenge_description: set_config[:description]
      )

      level_data[:puzzle_sets] << puzzle_set
    end

    level_data
  end

  # Generate a single puzzle set for a level using puzzle pool files
  def self.generate_puzzle_set(level:, set_index:, puzzles_count:, rating_range:, color_to_move: 'w', challenge: 'solve', challenge_description: nil)
    # For without_mistakes and move_combo challenges, use 2x the number of puzzles to provide variety
    actual_puzzles_count = (challenge == 'without_mistakes' || challenge == 'move_combo') ? puzzles_count * 2 : puzzles_count
    
    puts "  Generating puzzle set #{set_index} (#{puzzles_count} puzzles required, #{actual_puzzles_count} puzzles in pool, #{color_to_move == 'w' ? 'white' : 'black'} to move, #{challenge_description || challenge})"

    # Determine which pool file to use based on rating range and color
    pool_file_info = find_pool_file_for_rating_range(rating_range, color_to_move)
    
    if pool_file_info.nil?
      puts "    ERROR: No pool file found for rating range #{rating_range}"
      return {
        set_index: set_index,
        puzzles_count: 0,
        rating_range: rating_range,
        color_to_move: color_to_move,
        puzzles: []
      }
    end

    # Load puzzles from the pool file
    puzzle_ids = load_puzzles_from_pool_file(pool_file_info[:file_path], actual_puzzles_count)
    
    if puzzle_ids.empty?
      puts "    WARNING: No puzzles found in pool file #{pool_file_info[:filename]}"
      challenge_config = get_challenge_config(challenge)
      return {
        set_index: set_index,
        puzzles_count: 0,
        rating_range: rating_range,
        color_to_move: color_to_move,
        challenge: challenge,
        challenge_description: challenge_description,
        challenge_config: challenge_config,
        puzzles: []
      }
    end

    # Get puzzle data from database using the IDs from pool files
    puzzles = LichessV2Puzzle.where(puzzle_id: puzzle_ids).to_a

    if puzzles.length < puzzles_count
      puts "    WARNING: Only found #{puzzles.length} puzzles in database (requested #{puzzles_count})"
    end

    # Convert to simple list of puzzle IDs
    puzzle_ids = puzzles.map(&:puzzle_id)

    challenge_config = get_challenge_config(challenge)
    
    {
      set_index: set_index,
      puzzles_count: puzzles_count, # Required puzzles to solve
      puzzles_in_pool: puzzle_ids.length, # Actual puzzles in the pool
      rating_range: rating_range,
      color_to_move: color_to_move,
      challenge: challenge,
      challenge_description: challenge_description,
      challenge_config: challenge_config,
      puzzles: puzzle_ids
    }
  end

  # Find the appropriate pool file for a given rating range and color
  def self.find_pool_file_for_rating_range(rating_range, color_to_move = 'w')
    pools_dir = "data/puzzle-pools/"
    
    # Map rating ranges to pool file numbers
    pool_mapping = {
      (600..800) => 1,
      (800..1000) => 2,
      (1000..1200) => 3,
      (1200..1400) => 4,
      (1400..1600) => 5,
      (1600..1800) => 6,
      (1800..2000) => 7,
      (2000..2100) => 8,
      (2100..2300) => 9,
      (2300..3200) => 10
    }
    
    # Find the best matching pool
    best_pool = nil
    best_overlap = 0
    
    pool_mapping.each do |pool_range, pool_number|
      # Calculate overlap between the requested range and this pool
      overlap_start = [rating_range.min, pool_range.min].max
      overlap_end = [rating_range.max, pool_range.max].min
      overlap = [overlap_end - overlap_start + 1, 0].max
      
      # Choose the pool with the most overlap
      if overlap > best_overlap
        best_overlap = overlap
        best_pool = pool_number
      end
    end
    
    return nil unless best_pool
    
    # Use the specified color to move
    filename = "#{color_to_move}_pool_#{format("%02d", best_pool)}_#{pool_mapping.key(best_pool).min}-#{pool_mapping.key(best_pool).max}.txt"
    file_path = Rails.root.join(pools_dir, filename)
    
    if File.exist?(file_path)
      return {
        filename: filename,
        file_path: file_path,
        color: color_to_move,
        pool_number: best_pool,
        rating_range: pool_mapping.key(best_pool)
      }
    end
    
    nil
  end

  # Load puzzle IDs from a pool file
  def self.load_puzzles_from_pool_file(file_path, count)
    return [] unless File.exist?(file_path)
    
    pool_puzzle_data = File.readlines(file_path).map(&:strip).reject(&:empty?)
    return [] if pool_puzzle_data.empty?
    
    # Randomly sample the requested number of puzzles
    sampled_lines = pool_puzzle_data.sample(count)
    
    # Extract puzzle IDs from the lines
    puzzle_ids = sampled_lines.map do |line|
      parts = line.split("|", 3)
      parts[0] # puzzle_id is the first part
    end.compact
    
    puzzle_ids
  end

  # Expand rating range if not enough puzzles are available
  def self.expand_rating_range(original_range)
    min_rating = [original_range.min - 100, 400].max
    max_rating = [original_range.max + 100, 2500].min
    (min_rating..max_rating)
  end

  # Export a level to a JSON file
  def self.export_level(level_number, output_dir = "data/game-modes/adventure/")
    level_data = generate_level(level_number)
    
    # Ensure output directory exists
    full_output_dir = Rails.root.join(output_dir)
    FileUtils.mkdir_p(full_output_dir)
    
    # Create filename (removed "adventure-" prefix)
    filename = "level-#{level_number.to_s.rjust(2, '0')}.json"
    file_path = File.join(full_output_dir, filename)
    
    # Write level data to file
    File.write(file_path, JSON.pretty_generate(level_data))
    
    puts "✅ Exported Level #{level_number} to #{file_path}"
    
    {
      level: level_number,
      file: filename,
      path: file_path,
      puzzle_sets: level_data[:puzzle_sets].length,
      total_puzzles: level_data[:puzzle_sets].sum { |set| set[:puzzles_count] }
    }
  end

  # Export all levels to files
  def self.export_all_levels(output_dir = "data/game-modes/adventure/")
    puts "Exporting all adventure levels..."
    puts "Output directory: #{output_dir}"
    
    exported_files = []
    
    LEVEL_CONFIG.keys.sort.each do |level_number|
      puts "\n" + "="*50
      file_info = export_level(level_number, output_dir)
      exported_files << file_info
    end
    
    puts "\n" + "="*50
    puts "✅ Export complete!"
    puts "Exported #{exported_files.length} levels to #{Rails.root.join(output_dir)}"
    
    # Summary
    puts "\nSummary:"
    exported_files.each do |file_info|
      puts "  Level #{file_info[:level]}: #{file_info[:puzzle_sets]} sets, #{file_info[:total_puzzles]} puzzles"
    end
    
    exported_files
  end

  # Analyze puzzle availability for each level using pool files
  def self.analyze_level_availability
    puts "Analyzing puzzle availability for adventure levels..."
    
    analysis = {}
    
    LEVEL_CONFIG.each do |level_number, config|
      puts "\nAnalyzing Level #{level_number}: #{config[:description]}"
      puts "Rating range: #{config[:rating_range]}"
      
      # Check both white and black pool files for this level
      white_pool_info = find_pool_file_for_rating_range(config[:rating_range], 'w')
      black_pool_info = find_pool_file_for_rating_range(config[:rating_range], 'b')
      
      if white_pool_info.nil? && black_pool_info.nil?
        puts "  ❌ No pool files found for rating range #{config[:rating_range]}"
        analysis[level_number] = {
          config: config,
          available_puzzles: 0,
          needed_puzzles: 0,
          sufficient: false,
          coverage: 0.0,
          pool_files: []
        }
        next
      end
      
      # Calculate total available puzzles from both colors
      white_count = white_pool_info ? count_puzzles_in_pool_file(white_pool_info[:file_path]) : 0
      black_count = black_pool_info ? count_puzzles_in_pool_file(black_pool_info[:file_path]) : 0
      total_available = white_count + black_count
      
      # Calculate total puzzles needed
      total_needed = config[:puzzle_sets].sum { |set| set[:puzzles] }
      
      # Check if we have enough puzzles
      sufficient = total_available >= total_needed
      
      pool_files = []
      pool_files << white_pool_info[:filename] if white_pool_info
      pool_files << black_pool_info[:filename] if black_pool_info
      
      analysis[level_number] = {
        config: config,
        available_puzzles: total_available,
        needed_puzzles: total_needed,
        sufficient: sufficient,
        coverage: sufficient ? 100.0 : (total_available.to_f / total_needed * 100).round(1),
        pool_files: pool_files
      }
      
      status = sufficient ? "✅ SUFFICIENT" : "⚠️  INSUFFICIENT"
      puts "  Pool files: #{pool_files.join(', ')}"
      puts "  Available: #{total_available} puzzles (W: #{white_count}, B: #{black_count})"
      puts "  Needed: #{total_needed} puzzles"
      puts "  Status: #{status} (#{analysis[level_number][:coverage]}% coverage)"
    end
    
    puts "\n" + "="*50
    puts "Overall Analysis:"
    sufficient_levels = analysis.count { |_, data| data[:sufficient] }
    puts "Levels with sufficient puzzles: #{sufficient_levels}/#{analysis.length}"
    
    analysis
  end

  # Count puzzles in a pool file
  def self.count_puzzles_in_pool_file(file_path)
    return 0 unless File.exist?(file_path)
    
    pool_puzzle_data = File.readlines(file_path).map(&:strip).reject(&:empty?)
    pool_puzzle_data.length
  end

  # Get level configuration for a specific level
  def self.level_config(level_number)
    LEVEL_CONFIG[level_number]
  end

  # Get all available level numbers
  def self.available_levels
    LEVEL_CONFIG.keys.sort
  end

  # Validate that a level can be generated with sufficient puzzles
  def self.can_generate_level?(level_number)
    config = LEVEL_CONFIG[level_number]
    return false unless config

    # Check both white and black pool files
    white_pool_info = find_pool_file_for_rating_range(config[:rating_range], 'w')
    black_pool_info = find_pool_file_for_rating_range(config[:rating_range], 'b')
    
    return false if white_pool_info.nil? && black_pool_info.nil?

    # Count available puzzles from both colors
    white_count = white_pool_info ? count_puzzles_in_pool_file(white_pool_info[:file_path]) : 0
    black_count = black_pool_info ? count_puzzles_in_pool_file(black_pool_info[:file_path]) : 0
    total_available = white_count + black_count

    # Calculate total puzzles needed
    total_needed = config[:puzzle_sets].sum { |set| set[:puzzles] }

    total_available >= total_needed
  end
end
