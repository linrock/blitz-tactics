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
  # Level configuration - defines difficulty progression
  LEVEL_CONFIG = {
    1 => {
      puzzle_sets: 2,
      puzzles_per_set: 10,
      rating_range: (600..1000),
      description: "Beginner's Journey"
    },
    2 => {
      puzzle_sets: 3,
      puzzles_per_set: 10,
      rating_range: (700..1100),
      description: "Building Foundations"
    },
    3 => {
      puzzle_sets: 3,
      puzzles_per_set: 12,
      rating_range: (800..1200),
      description: "Growing Confidence"
    },
    4 => {
      puzzle_sets: 4,
      puzzles_per_set: 10,
      rating_range: (900..1300),
      description: "Stepping Up"
    },
    5 => {
      puzzle_sets: 4,
      puzzles_per_set: 12,
      rating_range: (1000..1400),
      description: "Intermediate Challenge"
    },
    6 => {
      puzzle_sets: 5,
      puzzles_per_set: 10,
      rating_range: (1100..1500),
      description: "Advanced Tactics"
    },
    7 => {
      puzzle_sets: 5,
      puzzles_per_set: 12,
      rating_range: (1200..1600),
      description: "Master's Path"
    },
    8 => {
      puzzle_sets: 6,
      puzzles_per_set: 10,
      rating_range: (1300..1700),
      description: "Expert Territory"
    },
    9 => {
      puzzle_sets: 6,
      puzzles_per_set: 12,
      rating_range: (1400..1800),
      description: "Elite Challenges"
    },
    10 => {
      puzzle_sets: 6,
      puzzles_per_set: [10, 10, 10, 20, 20, 20], # Mixed difficulty
      rating_range: (1500..1900),
      description: "Grandmaster Quest"
    }
  }.freeze

  # Generate a specific adventure level
  def self.generate_level(level_number)
    config = LEVEL_CONFIG[level_number]
    raise ArgumentError, "Level #{level_number} not defined" unless config

    puts "Generating Adventure Level #{level_number}: #{config[:description]}"
    puts "Rating range: #{config[:rating_range]}"
    puts "Puzzle sets: #{config[:puzzle_sets]}"

    level_data = {
      level: level_number,
      description: config[:description],
      rating_range: config[:rating_range],
      puzzle_sets: []
    }

    # Generate puzzle sets for this level
    config[:puzzle_sets].times do |set_index|
      puzzles_per_set = config[:puzzles_per_set].is_a?(Array) ? 
                       config[:puzzles_per_set][set_index] : 
                       config[:puzzles_per_set]

      puzzle_set = generate_puzzle_set(
        level: level_number,
        set_index: set_index + 1,
        puzzles_count: puzzles_per_set,
        rating_range: config[:rating_range]
      )

      level_data[:puzzle_sets] << puzzle_set
    end

    level_data
  end

  # Generate a single puzzle set for a level using puzzle pool files
  def self.generate_puzzle_set(level:, set_index:, puzzles_count:, rating_range:)
    puts "  Generating puzzle set #{set_index} (#{puzzles_count} puzzles)"

    # Determine which pool file to use based on rating range
    pool_file_info = find_pool_file_for_rating_range(rating_range)
    
    if pool_file_info.nil?
      puts "    ERROR: No pool file found for rating range #{rating_range}"
      return {
        set_index: set_index,
        puzzles_count: 0,
        rating_range: rating_range,
        puzzles: []
      }
    end

    # Load puzzles from the pool file
    puzzle_ids = load_puzzles_from_pool_file(pool_file_info[:file_path], puzzles_count)
    
    if puzzle_ids.empty?
      puts "    WARNING: No puzzles found in pool file #{pool_file_info[:filename]}"
      return {
        set_index: set_index,
        puzzles_count: 0,
        rating_range: rating_range,
        puzzles: []
      }
    end

    # Get puzzle data from database using the IDs from pool files
    puzzles = LichessV2Puzzle.where(puzzle_id: puzzle_ids).to_a

    if puzzles.length < puzzles_count
      puts "    WARNING: Only found #{puzzles.length} puzzles in database (requested #{puzzles_count})"
    end

    # Convert to the format expected by the game
    puzzle_data = puzzles.map do |puzzle|
      {
        id: puzzle.id,
        fen: puzzle.initial_fen,
        lines: puzzle.lines_tree, # Fixed: use lines_tree instead of solution_lines
        initialMove: {
          san: puzzle.initial_move_san,
          uci: puzzle.initial_move_uci
        }
      }
    end

    {
      set_index: set_index,
      puzzles_count: puzzle_data.length,
      rating_range: rating_range,
      puzzles: puzzle_data
    }
  end

  # Find the appropriate pool file for a given rating range
  def self.find_pool_file_for_rating_range(rating_range)
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
    
    # Try both colors and find the first available file
    %w[w b].each do |color|
      filename = "#{color}_pool_#{format("%02d", best_pool)}_#{pool_mapping.key(best_pool).min}-#{pool_mapping.key(best_pool).max}.txt"
      file_path = Rails.root.join(pools_dir, filename)
      
      if File.exist?(file_path)
        return {
          filename: filename,
          file_path: file_path,
          color: color,
          pool_number: best_pool,
          rating_range: pool_mapping.key(best_pool)
        }
      end
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
    
    # Create filename
    filename = "adventure-level-#{level_number.to_s.rjust(2, '0')}.json"
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
      
      # Find the appropriate pool file
      pool_file_info = find_pool_file_for_rating_range(config[:rating_range])
      
      if pool_file_info.nil?
        puts "  ❌ No pool file found for rating range #{config[:rating_range]}"
        analysis[level_number] = {
          config: config,
          available_puzzles: 0,
          needed_puzzles: 0,
          sufficient: false,
          coverage: 0.0,
          pool_file: nil
        }
        next
      end
      
      # Count available puzzles in pool file
      puzzle_count = count_puzzles_in_pool_file(pool_file_info[:file_path])
      
      # Calculate total puzzles needed
      total_needed = config[:puzzle_sets] * 
                    (config[:puzzles_per_set].is_a?(Array) ? 
                     config[:puzzles_per_set].sum : 
                     config[:puzzles_per_set])
      
      # Check if we have enough puzzles
      sufficient = puzzle_count >= total_needed
      
      analysis[level_number] = {
        config: config,
        available_puzzles: puzzle_count,
        needed_puzzles: total_needed,
        sufficient: sufficient,
        coverage: sufficient ? 100.0 : (puzzle_count.to_f / total_needed * 100).round(1),
        pool_file: pool_file_info[:filename]
      }
      
      status = sufficient ? "✅ SUFFICIENT" : "⚠️  INSUFFICIENT"
      puts "  Pool file: #{pool_file_info[:filename]}"
      puts "  Available: #{puzzle_count} puzzles"
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

    # Find the appropriate pool file
    pool_file_info = find_pool_file_for_rating_range(config[:rating_range])
    return false unless pool_file_info

    # Count available puzzles in pool file
    available = count_puzzles_in_pool_file(pool_file_info[:file_path])

    # Calculate total puzzles needed
    total_needed = config[:puzzle_sets] * 
                  (config[:puzzles_per_set].is_a?(Array) ? 
                   config[:puzzles_per_set].sum : 
                   config[:puzzles_per_set])

    available >= total_needed
  end
end
