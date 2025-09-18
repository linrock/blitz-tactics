# ThemedLevelCreator - Creates puzzle pools filtered by specific chess themes
#
# Usage Examples:
#   # Export opening theme pools to data/themes/opening/
#   ThemedLevelCreator.export_theme_pools_to_files(theme: "opening")
#
#   # Export fork theme pools with custom puzzle counts
#   ThemedLevelCreator.export_theme_pools_to_files(
#     theme: "fork",
#     puzzle_counts: {
#       (600..1000) => 5,
#       (1000..1400) => 10,
#       (1400..1800) => 15
#     }
#   )
#
#   # Create a puzzle set from opening theme pools
#   ThemedLevelCreator.create_puzzle_set_from_theme_pools(theme: "opening")
#
require 'set'

class ThemedLevelCreator
  # Default rating ranges and puzzle counts for themed puzzles
  DEFAULT_THEMED_PUZZLE_COUNTS = {
    (600..1000) => 10,
    (1000..1400) => 25,
    (1400..1800) => 30,
    (1800..2100) => 25,
    (2100..3200) => 10,
  }.freeze

  # Valid chess themes
  VALID_THEMES = %w[
    opening
    endgame
    pawnEndgame
    fork
    pin
    sacrifice
    skewer
    discoveredAttack
    doubleAttack
    deflection
    decoy
    interference
    overloadedPiece
    zwischenzug
    zugzwang
    mateIn1
    mateIn2
    mateIn3
    mateIn4
    mateIn5
    mateIn6
    mateIn7
    mateIn8
    mateIn9
    mateIn10
    advancedPawn
    backRankMate
    basicCheckmates
    bishopEndgame
    castling
    clearance
    defensiveMove
    enPassant
    exposedKing
    hangingPiece
    hookMate
    knightEndgame
    long
    master
    masterVsMaster
    mate
    middlegame
    oneMove
    pawnMate
    pin
    promotion
    queenEndgame
    queenRookEndgame
    quietMove
    rookEndgame
    royalFork
    short
    simplification
    skewer
    smotheredMate
    superGM
    trappedPiece
    underPromotion
    veryLong
    xRayAttack
    zugzwang
  ].freeze

  # Export ALL puzzle IDs for a specific theme to separate text files for each pool
  def self.export_theme_pools_to_files(theme:, output_dir: "data/themes/", puzzle_counts: DEFAULT_THEMED_PUZZLE_COUNTS)
    unless VALID_THEMES.include?(theme)
      raise ArgumentError, "Invalid theme '#{theme}'. Valid themes: #{VALID_THEMES.join(', ')}"
    end

    puts "Exporting #{theme} theme puzzle pools to text files..."
    puts "Output directory: #{output_dir}/#{theme}"
    puts "Note: Files contain ALL available puzzles in each rating range (not sampled)"
    
    # Ensure output directory exists
    theme_output_dir = File.join(Rails.root, output_dir, theme)
    FileUtils.mkdir_p(theme_output_dir)
    
    exported_files = []
    
    %w[w b].each do |color_to_move|
      puts "\nExporting #{color_to_move.upcase} to move #{theme} pools..."
      
      puzzle_counts.each_with_index do |(rating_range, _sample_count), index|
        pool_number = index + 1
        # Zero-padded pool number for natural sorting
        padded_pool_number = format("%02d", pool_number)
        filename = "#{color_to_move}_pool_#{padded_pool_number}_#{rating_range.min}-#{rating_range.max}.txt"
        file_path = File.join(theme_output_dir, filename)
        
        # Get ALL puzzle data for this pool with theme filter
        all_puzzles = LichessV2Puzzle
          .where(popularity: 90..)  # popularity > 95
          .where(num_plays: 800..) # num_plays > 1000
          .where(rating: rating_range)
          .where("initial_fen LIKE ?", "% #{color_to_move} %")  # Filter by color to move
          .where("themes @> ?", "{#{theme}}")  # Filter by theme
          .select(:puzzle_id, :themes, :rating)
        
        # Write puzzle data to file (one puzzle per line: puzzle_id|rating|themes)
        puzzle_lines = all_puzzles.map do |puzzle|
          themes_str = (puzzle.themes || []).join(",")
          "#{puzzle.puzzle_id}|#{puzzle.rating}|#{themes_str}"
        end
        
        File.write(file_path, puzzle_lines.join("\n"))
        
        exported_files << {
          file: filename,
          path: file_path,
          pool: "#{color_to_move.upcase} #{theme.capitalize} Pool #{padded_pool_number}",
          rating_range: rating_range,
          total_count: all_puzzles.length
        }
        
        puts "  #{filename}: #{all_puzzles.length} puzzles (#{rating_range})"
      end
    end
    
    puts "\n✅ Export complete!"
    puts "Exported #{exported_files.length} files to #{theme_output_dir}"
    
    # Summary
    puts "\nSummary:"
    exported_files.each do |file_info|
      puts "  #{file_info[:file]}: #{file_info[:total_count]} puzzles"
    end
    
    # Summary by color to move
    puts "\nSummary by color to move:"
    %w[w b].each do |color_to_move|
      color_files = exported_files.select { |f| f[:file].start_with?("#{color_to_move}_") }
      total_puzzles = color_files.sum { |f| f[:total_count] }
      puts "  #{color_to_move.upcase} to move: #{total_puzzles} puzzles (#{color_files.length} pools)"
    end
    
    total_all_puzzles = exported_files.sum { |f| f[:total_count] }
    puts "  Total: #{total_all_puzzles} puzzles (#{exported_files.length} pools)"
    
    exported_files
  end

  # Utility method to analyze theme pool sizes
  def self.analyze_theme_pool_sizes(theme:, puzzle_counts: DEFAULT_THEMED_PUZZLE_COUNTS)
    unless VALID_THEMES.include?(theme)
      raise ArgumentError, "Invalid theme '#{theme}'. Valid themes: #{VALID_THEMES.join(', ')}"
    end

    analysis = {}
    
    %w[w b].each do |color_to_move|
      analysis[color_to_move] = {}
      
      puzzle_counts.each do |rating_range, _count|
        count = LichessV2Puzzle
          .where(popularity: 90..)
          .where(num_plays: 800..)
          .where(rating: rating_range)
          .where("initial_fen LIKE ?", "% #{color_to_move} %")
          .where("themes @> ?", "{#{theme}}")
          .count
        
        analysis[color_to_move][rating_range] = count
      end
    end
    
    analysis
  end

  # Create puzzle sets from pre-computed theme pool files
  def self.create_puzzle_set_from_theme_pools(theme:, puzzle_counts: DEFAULT_THEMED_PUZZLE_COUNTS, prioritize_theme_variety: true, pools_dir: "data/themes/")
    unless VALID_THEMES.include?(theme)
      raise ArgumentError, "Invalid theme '#{theme}'. Valid themes: #{VALID_THEMES.join(', ')}"
    end

    puts "Creating #{theme} theme puzzle set from pre-computed pools..."
    puts "Prioritize theme variety: #{prioritize_theme_variety}"
    puts "Puzzle counts per range:"
    puzzle_counts.each do |range, count|
      puts "  #{range}: #{count} puzzles"
    end
    
    selected_puzzle_ids = []
    
    %w[w b].each do |color_to_move|
      puts "\nProcessing #{color_to_move.upcase} to move #{theme} pools..."
      
      puzzle_counts.each_with_index do |(rating_range, sample_count), index|
        pool_number = index + 1
        padded_pool_number = format("%02d", pool_number)
        filename = "#{color_to_move}_pool_#{padded_pool_number}_#{rating_range.min}-#{rating_range.max}.txt"
        file_path = File.join(Rails.root, pools_dir, theme, filename)
        
        # Read puzzle IDs from file
        if File.exist?(file_path)
          pool_puzzle_ids = File.readlines(file_path).map(&:strip).reject(&:empty?)
          
          if pool_puzzle_ids.any?
            if prioritize_theme_variety
              # Get puzzles with theme information for variety sampling
              puzzles_with_themes = LichessV2Puzzle
                .where(puzzle_id: pool_puzzle_ids)
                .select(:puzzle_id, :themes)
              
              if puzzles_with_themes.any?
                sampled_puzzles = sample_with_theme_variety(puzzles_with_themes, sample_count)
                sampled_ids = sampled_puzzles.map(&:puzzle_id)
              else
                sampled_ids = pool_puzzle_ids.sample(sample_count)
              end
            else
              # Random sampling
              sampled_ids = pool_puzzle_ids.sample(sample_count)
            end
            
            selected_puzzle_ids.concat(sampled_ids)
            puts "  #{filename}: #{sampled_ids.length}/#{pool_puzzle_ids.length} puzzles selected"
          else
            puts "  #{filename}: No puzzles in pool"
          end
        else
          puts "  #{filename}: File not found"
        end
      end
    end
    
    puts "\n✅ Puzzle set creation complete!"
    puts "Total puzzles selected: #{selected_puzzle_ids.length}"
    
    # Create puzzle data for the selected puzzles
    puzzle_data = selected_puzzle_ids.map do |puzzle_id|
      puzzle = LichessV2Puzzle.find_by(puzzle_id: puzzle_id)
      if puzzle
        puzzle.bt_puzzle_data
      else
        puts "Warning: Puzzle #{puzzle_id} not found in database"
        nil
      end
    end.compact
    
    puts "Valid puzzles: #{puzzle_data.length}"
    
    puzzle_data
  end

  # Fast puzzle set creation from theme pools (no theme variety optimization)
  def self.create_theme_puzzle_set_fast(theme:, puzzle_counts: DEFAULT_THEMED_PUZZLE_COUNTS, pools_dir: "data/themes/")
    unless VALID_THEMES.include?(theme)
      raise ArgumentError, "Invalid theme '#{theme}'. Valid themes: #{VALID_THEMES.join(', ')}"
    end

    selected_puzzle_ids = []
    
    %w[w b].each do |color_to_move|
      puzzle_counts.each_with_index do |(rating_range, sample_count), index|
        pool_number = index + 1
        padded_pool_number = format("%02d", pool_number)
        filename = "#{color_to_move}_pool_#{padded_pool_number}_#{rating_range.min}-#{rating_range.max}.txt"
        file_path = File.join(Rails.root, pools_dir, theme, filename)
        
        if File.exist?(file_path)
          pool_puzzle_lines = File.readlines(file_path).map(&:strip).reject(&:empty?)
          pool_puzzle_ids = pool_puzzle_lines.map { |line| line.split("|", 3)[0] }
          sampled_ids = pool_puzzle_ids.sample(sample_count)
          selected_puzzle_ids.concat(sampled_ids)
        end
      end
    end
    
    # Create puzzle data for the selected puzzles
    puzzle_data = selected_puzzle_ids.map do |puzzle_id|
      puzzle = LichessV2Puzzle.find_by(puzzle_id: puzzle_id)
      puzzle&.bt_puzzle_data
    end.compact
    
    puzzle_data
  end

  # Fast puzzle set creation from theme pools for a single color only
  def self.create_theme_puzzle_set_fast_single_color(theme:, color_to_move:, puzzle_counts: DEFAULT_THEMED_PUZZLE_COUNTS, pools_dir: "data/themes/")
    unless VALID_THEMES.include?(theme)
      raise ArgumentError, "Invalid theme '#{theme}'. Valid themes: #{VALID_THEMES.join(', ')}"
    end

    unless %w[w b].include?(color_to_move)
      raise ArgumentError, "Invalid color_to_move '#{color_to_move}'. Must be 'w' or 'b'"
    end

    selected_puzzle_ids = []
    
    puzzle_counts.each_with_index do |(rating_range, sample_count), index|
      pool_number = index + 1
      padded_pool_number = format("%02d", pool_number)
      filename = "#{color_to_move}_pool_#{padded_pool_number}_#{rating_range.min}-#{rating_range.max}.txt"
      file_path = File.join(Rails.root, pools_dir, theme, filename)
      
      if File.exist?(file_path)
        pool_puzzle_lines = File.readlines(file_path).map(&:strip).reject(&:empty?)
        pool_puzzle_ids = pool_puzzle_lines.map { |line| line.split("|", 3)[0] }
        sampled_ids = pool_puzzle_ids.sample(sample_count)
        selected_puzzle_ids.concat(sampled_ids)
      end
    end
    
    # Create puzzle data for the selected puzzles
    puzzle_data = selected_puzzle_ids.map do |puzzle_id|
      puzzle = LichessV2Puzzle.find_by(puzzle_id: puzzle_id)
      puzzle&.bt_puzzle_data
    end.compact
    
    puzzle_data
  end

  # Helper method to sample puzzles with theme variety (copied from LevelCreator)
  private_class_method def self.sample_with_theme_variety(puzzles_with_themes, sample_count)
    return puzzles_with_themes.sample(sample_count) if puzzles_with_themes.length <= sample_count
    
    # Count theme occurrences across all puzzles
    theme_counts = Hash.new(0)
    puzzles_with_themes.each do |puzzle|
      (puzzle.themes || []).each { |theme| theme_counts[theme] += 1 }
    end
    
    # Sort themes by rarity (ascending count)
    themes_by_rarity = theme_counts.sort_by { |_theme, count| count }.map(&:first)
    
    selected_puzzles = []
    remaining_puzzles = puzzles_with_themes.dup
    
    # First pass: select one puzzle from each rare theme
    themes_by_rarity.each do |theme|
      break if selected_puzzles.length >= sample_count
      
      puzzle_with_theme = remaining_puzzles.find { |p| (p.themes || []).include?(theme) }
      if puzzle_with_theme
        selected_puzzles << puzzle_with_theme
        remaining_puzzles.delete(puzzle_with_theme)
      end
    end
    
    # Second pass: fill remaining slots with random selection
    while selected_puzzles.length < sample_count && remaining_puzzles.any?
      selected_puzzles << remaining_puzzles.sample
      remaining_puzzles.delete(selected_puzzles.last)
    end
    
    selected_puzzles
  end

  # Helper method to create custom puzzle count configurations
  def self.create_custom_config(ranges_and_counts)
    ranges_and_counts.transform_keys do |key|
      case key
      when String
        # Parse string like "600-800" into range
        min, max = key.split('-').map(&:to_i)
        min..max
      when Range
        key
      else
        raise ArgumentError, "Invalid range format: #{key}"
      end
    end
  end

  # List all available themes
  def self.list_themes
    puts "Available chess themes:"
    VALID_THEMES.each_with_index do |theme, index|
      puts "  #{index + 1}. #{theme}"
    end
    puts "\nTotal: #{VALID_THEMES.length} themes"
  end

  # Get theme statistics
  def self.theme_stats(theme:)
    unless VALID_THEMES.include?(theme)
      raise ArgumentError, "Invalid theme '#{theme}'. Valid themes: #{VALID_THEMES.join(', ')}"
    end

    total_puzzles = LichessV2Puzzle
      .where(popularity: 95..)
      .where(num_plays: 1000..)
      .where("themes @> ?", "{#{theme}}")
      .count

    white_puzzles = LichessV2Puzzle
      .where(popularity: 95..)
      .where(num_plays: 1000..)
      .where("initial_fen LIKE ?", "% w %")
      .where("themes @> ?", "{#{theme}}")
      .count

    black_puzzles = LichessV2Puzzle
      .where(popularity: 95..)
      .where(num_plays: 1000..)
      .where("initial_fen LIKE ?", "% b %")
      .where("themes @> ?", "{#{theme}}")
      .count

    puts "#{theme.capitalize} Theme Statistics:"
    puts "  Total puzzles: #{total_puzzles}"
    puts "  White to move: #{white_puzzles}"
    puts "  Black to move: #{black_puzzles}"
    puts "  Average rating: #{LichessV2Puzzle.where(popularity: 95..).where(num_plays: 1000..).where("themes @> ?", "{#{theme}}").average(:rating)&.round(1) || 'N/A'}"

    {
      total: total_puzzles,
      white_to_move: white_puzzles,
      black_to_move: black_puzzles
    }
  end
end
