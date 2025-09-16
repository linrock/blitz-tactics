# ThreeLevelCreator - Generates puzzle pool text files for fast retrieval
#
# Usage Examples:
#   # Export all pools to text files
#   ThreeLevelCreator.export_pools_to_files("data/game-modes/three/")
#
#   # Analyze pool sizes
#   analysis = ThreeLevelCreator.analyze_pool_sizes
#
# Rake Tasks:
#   rake three:export_pools[data/game-modes/three/] # Export pools to text files
#   rake three:analyze                              # Analyze pool sizes
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

end
