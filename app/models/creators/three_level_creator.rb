# ThreeLevelCreator - Generates precomputed puzzle lists for fast retrieval
#
# Usage Examples:
#   # Generate 10 levels with 200 puzzles each (10 per pool)
#   ThreeLevelCreator.generate_and_save_levels(10, 200, "three_levels.json")
#
#   # Load a random level
#   puzzle_ids = ThreeLevelCreator.get_random_level("three_levels.json")
#
#   # Analyze pool sizes
#   analysis = ThreeLevelCreator.analyze_pool_sizes
#
# Rake Tasks:
#   rake three:generate[10,200,three_levels.json]  # Generate levels
#   rake three:analyze                              # Analyze pool sizes
#   rake three:test_load[three_levels.json]        # Test loading
#   rake three:export_pools[data/game-modes/three/] # Export pools to text files
#
class ThreeLevelCreator
  # 20 pools: 10 for white to move, 10 for black to move
  # Each pool has ascending rating ranges starting from 600
  RATING_RANGES = {
    'w' => [
      (600..800),   # Pool 1: White, 600-800
      (800..1000),  # Pool 2: White, 800-1000
      (1000..1200), # Pool 3: White, 1000-1200
      (1200..1400), # Pool 4: White, 1200-1400
      (1400..1600), # Pool 5: White, 1400-1600
      (1600..1700), # Pool 6: White, 1600-1700
      (1700..1800), # Pool 7: White, 1700-1800
      (1800..1900), # Pool 8: White, 1800-1900
      (1900..2000), # Pool 9: White, 1900-2000
      (2000..2100)  # Pool 10: White, 2000-2100
    ],
    'b' => [
      (600..800),   # Pool 11: Black, 600-800
      (800..1000),  # Pool 12: Black, 800-1000
      (1000..1200), # Pool 13: Black, 1000-1200
      (1200..1400), # Pool 14: Black, 1200-1400
      (1400..1600), # Pool 15: Black, 1400-1600
      (1600..1700), # Pool 16: Black, 1600-1700
      (1700..1800), # Pool 17: Black, 1700-1800
      (1800..1900), # Pool 18: Black, 1800-1900
      (1900..2000), # Pool 19: Black, 1900-2000
      (2000..2100)  # Pool 20: Black, 2000-2100
    ]
  }.freeze

  def self.generate_level(n = 200)
    # 10 puzzles from each of the 20 pools = 200 total puzzles
    puzzles_per_pool = n / 20
    
    level_puzzle_ids = []
    
    # Generate puzzles for each color and rating range
    RATING_RANGES.each do |color_to_move, rating_ranges|
      rating_ranges.each do |rating_range|
        pool_puzzle_ids = get_puzzle_ids_for_pool(color_to_move, rating_range, puzzles_per_pool)
        level_puzzle_ids.concat(pool_puzzle_ids)
      end
    end
    
    level_puzzle_ids
  end

  def self.generate_multiple_levels(count = 10, puzzles_per_level = 100)
    levels = []
    
    count.times do |level_index|
      puts "Generating level #{level_index + 1}/#{count}..."
      level_puzzle_ids = generate_level(puzzles_per_level)
      levels << {
        level_id: level_index + 1,
        puzzle_ids: level_puzzle_ids,
        generated_at: Time.current
      }
    end
    
    levels
  end

  def self.save_levels_to_file(levels, filename = "three_levels.json")
    file_path = Rails.root.join("data", filename)
    
    # Ensure data directory exists
    FileUtils.mkdir_p(File.dirname(file_path))
    
    # Save to JSON file
    File.write(file_path, JSON.pretty_generate(levels))
    
    puts "Saved #{levels.length} levels to #{file_path}"
    file_path
  end

  def self.load_levels_from_file(filename = "three_levels.json")
    file_path = Rails.root.join("data", filename)
    
    return [] unless File.exist?(file_path)
    
    JSON.parse(File.read(file_path))
  end

  def self.get_random_level(filename = "three_levels.json")
    levels = load_levels_from_file(filename)
    return [] if levels.empty?
    
    random_level = levels.sample
    random_level["puzzle_ids"]
  end

  private

  def self.get_puzzle_ids_for_pool(color_to_move, rating_range, count)
    # Get puzzle IDs from the specified pool
    puzzle_ids = LichessV2Puzzle
      .where(popularity: 96..)  # popularity > 95
      .where(num_plays: 1001..) # num_plays > 1000
      .where(rating: rating_range)
      .where("initial_fen LIKE ?", "% #{color_to_move} %")  # Filter by color to move
      .limit(count * 3)  # Get 3x what we need for sampling
      .pluck(:puzzle_id)
      .sample(count)  # Randomly sample the requested count
    
    puzzle_ids
  end

  # Utility method to analyze pool sizes
  def self.analyze_pool_sizes
    analysis = {}
    
    RATING_RANGES.each do |color_to_move, rating_ranges|
      analysis[color_to_move] = {}
      
      rating_ranges.each do |rating_range|
        count = LichessV2Puzzle
          .where(popularity: 96..)
          .where(num_plays: 1001..)
          .where(rating: rating_range)
          .where("initial_fen LIKE ?", "% #{color_to_move} %")
          .count
        
        analysis[color_to_move][rating_range] = count
      end
    end
    
    analysis
  end

  # Export puzzle IDs to separate text files for each pool
  def self.export_pools_to_files(output_dir = "data/game-modes/three/")
    puts "Exporting puzzle pools to text files..."
    puts "Output directory: #{output_dir}"
    
    # Ensure output directory exists
    full_output_dir = Rails.root.join(output_dir)
    FileUtils.mkdir_p(full_output_dir)
    
    exported_files = []
    
    RATING_RANGES.each do |color_to_move, rating_ranges|
      puts "\nExporting #{color_to_move.upcase} to move pools..."
      
      rating_ranges.each_with_index do |rating_range, index|
        pool_number = index + 1
        filename = "#{color_to_move}_pool_#{pool_number}_#{rating_range.min}-#{rating_range.max}.txt"
        file_path = File.join(full_output_dir, filename)
        
        # Get all puzzle IDs for this pool
        puzzle_ids = LichessV2Puzzle
          .where(popularity: 96..)  # popularity > 95
          .where(num_plays: 1001..) # num_plays > 1000
          .where(rating: rating_range)
          .where("initial_fen LIKE ?", "% #{color_to_move} %")  # Filter by color to move
          .pluck(:puzzle_id)
        
        # Write to file (one ID per line)
        File.write(file_path, puzzle_ids.join("\n"))
        
        exported_files << {
          file: filename,
          path: file_path,
          pool: "#{color_to_move.upcase} Pool #{pool_number}",
          rating_range: rating_range,
          count: puzzle_ids.length
        }
        
        puts "  #{filename}: #{puzzle_ids.length} puzzles (#{rating_range})"
      end
    end
    
    puts "\n✅ Export complete!"
    puts "Exported #{exported_files.length} files to #{full_output_dir}"
    
    # Summary
    puts "\nSummary:"
    exported_files.each do |file_info|
      puts "  #{file_info[:file]}: #{file_info[:count]} puzzles"
    end
    
    exported_files
  end

  # Utility method to generate and save levels
  def self.generate_and_save_levels(count = 10, puzzles_per_level = 200, filename = "three_levels.json")
    puts "Generating #{count} levels with #{puzzles_per_level} puzzles each..."
    puts "Analyzing pool sizes first..."
    
    # Analyze pool sizes
    pool_analysis = analyze_pool_sizes
    puts "Pool analysis:"
    pool_analysis.each do |color, ranges|
      puts "  #{color.upcase} to move:"
      ranges.each do |range, count|
        puts "    #{range}: #{count} puzzles"
      end
    end
    
    # Generate levels
    levels = generate_multiple_levels(count, puzzles_per_level)
    
    # Save to file
    file_path = save_levels_to_file(levels, filename)
    
    puts "Generation complete!"
    puts "File saved to: #{file_path}"
    
    file_path
  end
end
