# LevelCreator - Generic puzzle pool generator with configurable sampling
#
# Usage Examples:
#   # Export pools with custom puzzle counts per range
#   LevelCreator.export_pools_to_files(
#     output_dir: "data/puzzle-pools/",
#     puzzle_counts: {
#       (600..800) => 5,
#       (800..1000) => 10,
#       (1000..1200) => 15,
#       (1200..1400) => 20,
#       (1400..1600) => 25,
#       (1600..1800) => 30,
#       (1800..2000) => 35,
#       (2000..2200) => 40
#     }
#   )
#
#   # Analyze pool sizes
#   analysis = LevelCreator.analyze_pool_sizes
#
class LevelCreator
  # Default rating ranges and puzzle counts
  DEFAULT_PUZZLE_COUNTS = {
    (600..800) => 5,
    (800..1000) => 5,
    (1000..1200) => 10,
    (1200..1400) => 15,
    (1400..1600) => 15,
    (1600..1800) => 15,
    (1800..2000) => 10,
    (2000..2100) => 10,
    (2100..2300) => 5,
    (2300..3200) => 5,
  }.freeze

  # Utility method to analyze pool sizes
  def self.analyze_pool_sizes(puzzle_counts = DEFAULT_PUZZLE_COUNTS)
    analysis = {}
    
    %w[w b].each do |color_to_move|
      analysis[color_to_move] = {}
      
      puzzle_counts.each do |rating_range, _count|
        count = LichessV2Puzzle
          .where(popularity: 96..)
          .where(num_plays: 1000..)
          .where(rating: rating_range)
          .where("initial_fen LIKE ?", "% #{color_to_move} %")
          .count
        
        analysis[color_to_move][rating_range] = count
      end
    end
    
    analysis
  end

  # Export ALL puzzle IDs to separate text files for each pool (for real-time puzzle set creation)
  def self.export_pools_to_files(output_dir: "data/puzzle-pools/", puzzle_counts: DEFAULT_PUZZLE_COUNTS)
    puts "Exporting complete puzzle pools to text files..."
    puts "Output directory: #{output_dir}"
    puts "Note: Files contain ALL available puzzles in each rating range (not sampled)"
    
    # Ensure output directory exists
    full_output_dir = Rails.root.join(output_dir)
    FileUtils.mkdir_p(full_output_dir)
    
    exported_files = []
    
    %w[w b].each do |color_to_move|
      puts "\nExporting #{color_to_move.upcase} to move pools..."
      
      puzzle_counts.each_with_index do |(rating_range, _sample_count), index|
        pool_number = index + 1
        # Zero-padded pool number for natural sorting
        padded_pool_number = format("%02d", pool_number)
        filename = "#{color_to_move}_pool_#{padded_pool_number}_#{rating_range.min}-#{rating_range.max}.txt"
        file_path = File.join(full_output_dir, filename)
        
        # Get ALL puzzle IDs for this pool (no sampling)
        all_puzzle_ids = LichessV2Puzzle
          .where(popularity: 95..)  # popularity > 95
          .where(num_plays: 1000..) # num_plays > 1000
          .where(rating: rating_range)
          .where("initial_fen LIKE ?", "% #{color_to_move} %")  # Filter by color to move
          .pluck(:puzzle_id)
        
        # Write ALL puzzle IDs to file (one ID per line)
        File.write(file_path, all_puzzle_ids.join("\n"))
        
        exported_files << {
          file: filename,
          path: file_path,
          pool: "#{color_to_move.upcase} Pool #{padded_pool_number}",
          rating_range: rating_range,
          total_count: all_puzzle_ids.length
        }
        
        puts "  #{filename}: #{all_puzzle_ids.length} puzzles (#{rating_range})"
      end
    end
    
    puts "\n✅ Export complete!"
    puts "Exported #{exported_files.length} files to #{full_output_dir}"
    
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

  # Create puzzle sets from pre-computed pool files with theme variety
  def self.create_puzzle_set_from_pools(puzzle_counts: DEFAULT_PUZZLE_COUNTS, prioritize_theme_variety: true, pools_dir: "data/puzzle-pools/")
    puts "Creating puzzle set from pre-computed pools..."
    puts "Prioritize theme variety: #{prioritize_theme_variety}"
    puts "Puzzle counts per range:"
    puzzle_counts.each do |range, count|
      puts "  #{range}: #{count} puzzles"
    end
    
    selected_puzzle_ids = []
    
    %w[w b].each do |color_to_move|
      puts "\nProcessing #{color_to_move.upcase} to move pools..."
      
      puzzle_counts.each_with_index do |(rating_range, sample_count), index|
        pool_number = index + 1
        padded_pool_number = format("%02d", pool_number)
        filename = "#{color_to_move}_pool_#{padded_pool_number}_#{rating_range.min}-#{rating_range.max}.txt"
        file_path = Rails.root.join(pools_dir, filename)
        
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
    
    # Summary by color to move
    puts "\nSummary by color to move:"
    %w[w b].each do |color_to_move|
      color_count = 0
      puzzle_counts.each_with_index do |(rating_range, sample_count), index|
        pool_number = index + 1
        padded_pool_number = format("%02d", pool_number)
        filename = "#{color_to_move}_pool_#{padded_pool_number}_#{rating_range.min}-#{rating_range.max}.txt"
        file_path = Rails.root.join(pools_dir, filename)
        
        if File.exist?(file_path)
          pool_puzzle_ids = File.readlines(file_path).map(&:strip).reject(&:empty?)
          if pool_puzzle_ids.any?
            if prioritize_theme_variety
              puzzles_with_themes = LichessV2Puzzle
                .where(puzzle_id: pool_puzzle_ids)
                .select(:puzzle_id, :themes)
              
              if puzzles_with_themes.any?
                sampled_puzzles = sample_with_theme_variety(puzzles_with_themes, sample_count)
                color_count += sampled_puzzles.length
              else
                color_count += [sample_count, pool_puzzle_ids.length].min
              end
            else
              color_count += [sample_count, pool_puzzle_ids.length].min
            end
          end
        end
      end
      puts "  #{color_to_move.upcase} to move: #{color_count} puzzles"
    end
    
    selected_puzzle_ids
  end

  # Create a level by sampling puzzles from pre-computed pool files
  # Chooses a random color to move and ensures theme diversity within each pool
  def self.create_level_from_pools(puzzle_counts: DEFAULT_PUZZLE_COUNTS, pools_dir: "data/puzzle-pools/")
    # Choose random color to move
    color_to_move = %w[w b].sample
    
    puts "Creating level with #{color_to_move.upcase} to move..."
    puts "Puzzle counts per range:"
    puzzle_counts.each do |range, count|
      puts "  #{range}: #{count} puzzles"
    end
    
    selected_puzzle_ids = []
    
    puzzle_counts.each_with_index do |(rating_range, sample_count), index|
      pool_number = index + 1
      padded_pool_number = format("%02d", pool_number)
      filename = "#{color_to_move}_pool_#{padded_pool_number}_#{rating_range.min}-#{rating_range.max}.txt"
      file_path = Rails.root.join(pools_dir, filename)
      
      # Read puzzle IDs from file
      if File.exist?(file_path)
        pool_puzzle_ids = File.readlines(file_path).map(&:strip).reject(&:empty?)
        
        if pool_puzzle_ids.any?
          # Fast sampling with limited theme variety (no database queries)
          sampled_ids = sample_with_limited_theme_variety(pool_puzzle_ids, sample_count)
          
          selected_puzzle_ids.concat(sampled_ids)
          puts "  #{filename}: #{sampled_ids.length}/#{pool_puzzle_ids.length} puzzles selected"
        else
          puts "  #{filename}: No puzzles in pool"
        end
      else
        puts "  #{filename}: File not found"
      end
    end
    
    puts "\n✅ Level creation complete!"
    puts "Color to move: #{color_to_move.upcase}"
    puts "Total puzzles selected: #{selected_puzzle_ids.length}"
    
    selected_puzzle_ids
  end

  # Example usage method
  def self.export_example_pools
    custom_config = create_custom_config({
      "600-800" => 5,
      "800-1000" => 5,
      "1000-1200" => 10,
      "1200-1400" => 15,
      "1400-1600" => 15,
      "1600-1800" => 15,
      "1800-2000" => 10,
      "2000-2100" => 10,
      "2100-2300" => 5,
      "2300-3200" => 5
    })
    
    export_pools_to_files(
      output_dir: "data/puzzle-pools/",
      puzzle_counts: custom_config
    )
  end

  private

  # Fast sampling with limited theme variety (no database queries)
  # Uses puzzle ID patterns to estimate theme diversity
  def self.sample_with_limited_theme_variety(puzzle_ids, sample_count)
    return puzzle_ids.sample(sample_count) if puzzle_ids.length <= sample_count
    
    # Shuffle the pool to randomize order
    shuffled_ids = puzzle_ids.shuffle
    
    # Use a simple distribution strategy to ensure variety
    # Take puzzles from different parts of the shuffled list
    selected_ids = []
    
    if sample_count <= 3
      # For small samples, just take from different parts
      step = [shuffled_ids.length / sample_count, 1].max
      (0...sample_count).each do |i|
        index = (i * step) % shuffled_ids.length
        selected_ids << shuffled_ids[index]
      end
    else
      # For larger samples, use a more sophisticated distribution
      # Divide the pool into segments and sample from each
      num_segments = [sample_count / 3, 5].min  # Use 3-5 segments
      segment_size = shuffled_ids.length / num_segments
      
      puzzles_per_segment = sample_count / num_segments
      remaining_puzzles = sample_count % num_segments
      
      (0...num_segments).each do |segment|
        start_idx = segment * segment_size
        end_idx = start_idx + segment_size - 1
        segment_ids = shuffled_ids[start_idx..end_idx] || []
        
        # Add one extra puzzle to some segments if there's a remainder
        count_for_segment = puzzles_per_segment + (segment < remaining_puzzles ? 1 : 0)
        
        if segment_ids.any?
          selected_from_segment = segment_ids.sample([count_for_segment, segment_ids.length].min)
          selected_ids.concat(selected_from_segment)
        end
      end
      
      # If we still need more puzzles, fill randomly
      if selected_ids.length < sample_count
        remaining_needed = sample_count - selected_ids.length
        available_ids = shuffled_ids - selected_ids
        additional_ids = available_ids.sample(remaining_needed)
        selected_ids.concat(additional_ids)
      end
    end
    
    # Shuffle the final selection to avoid any patterns
    selected_ids.shuffle
  end

  # Sample puzzles with theme variety to avoid getting all puzzles of the same theme
  def self.sample_with_theme_variety(puzzles, sample_count)
    return puzzles.sample(sample_count) if puzzles.length <= sample_count
    
    # Group puzzles by their primary theme (first theme in the array)
    theme_groups = puzzles.group_by { |puzzle| puzzle.themes.first || "unknown" }
    
    # Calculate how many puzzles to take from each theme group
    selected_puzzles = []
    remaining_count = sample_count
    
    # First pass: try to get at least one puzzle from each theme
    theme_groups.each do |theme, theme_puzzles|
      if remaining_count > 0 && theme_puzzles.any?
        selected_puzzles << theme_puzzles.sample(1).first
        remaining_count -= 1
      end
    end
    
    # Second pass: distribute remaining puzzles proportionally
    if remaining_count > 0
      # Calculate proportional distribution
      total_remaining_puzzles = puzzles.length - selected_puzzles.length
      
      theme_groups.each do |theme, theme_puzzles|
        next if remaining_count <= 0
        
        # Calculate how many more puzzles this theme should contribute
        theme_proportion = theme_puzzles.length.to_f / total_remaining_puzzles
        additional_count = [(theme_proportion * remaining_count).round, remaining_count, theme_puzzles.length - 1].min
        
        if additional_count > 0
          # Get additional puzzles from this theme (excluding already selected ones)
          available_puzzles = theme_puzzles - selected_puzzles
          additional_puzzles = available_puzzles.sample(additional_count)
          selected_puzzles.concat(additional_puzzles)
          remaining_count -= additional_puzzles.length
        end
      end
    end
    
    # If we still need more puzzles, fill with random selection
    if remaining_count > 0
      available_puzzles = puzzles - selected_puzzles
      additional_puzzles = available_puzzles.sample(remaining_count)
      selected_puzzles.concat(additional_puzzles)
    end
    
    # Shuffle the final selection to avoid theme clustering
    selected_puzzles.shuffle
  end

  # Analyze theme distribution in a pool
  def self.analyze_theme_distribution(puzzles)
    theme_counts = Hash.new(0)
    
    puzzles.each do |puzzle|
      primary_theme = puzzle.themes.first || "unknown"
      theme_counts[primary_theme] += 1
    end
    
    theme_counts
  end

  # Analyze theme distribution across all pools
  def self.analyze_theme_distribution_across_pools(puzzle_counts = DEFAULT_PUZZLE_COUNTS)
    puts "Analyzing theme distribution across all pools..."
    puts "=" * 60
    
    %w[w b].each do |color_to_move|
      puts "\n#{color_to_move.upcase} to move:"
      
      puzzle_counts.each_with_index do |(rating_range, sample_count), index|
        pool_number = index + 1
        
        # Get all puzzles for this pool
        all_puzzles = LichessV2Puzzle
          .where(popularity: 96..)
          .where(num_plays: 1001..)
          .where(rating: rating_range)
          .where("initial_fen LIKE ?", "% #{color_to_move} %")
          .select(:puzzle_id, :themes)
        
        if all_puzzles.any?
          theme_distribution = analyze_theme_distribution(all_puzzles)
          total_puzzles = all_puzzles.length
          
          puts "  Pool #{pool_number} (#{rating_range}): #{total_puzzles} total puzzles"
          theme_distribution.sort_by { |theme, count| -count }.each do |theme, count|
            percentage = (count * 100.0 / total_puzzles).round(1)
            puts "    #{theme}: #{count} (#{percentage}%)"
          end
        else
          puts "  Pool #{pool_number} (#{rating_range}): No puzzles found"
        end
      end
    end
  end
end
