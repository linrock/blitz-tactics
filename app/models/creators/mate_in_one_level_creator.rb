# Mate-in-one Level Creator using ThemedLevelCreator
# Creates levels specifically for mate-in-one puzzles

module MateInOneLevelCreator
  # Default puzzle counts for mate-in-one mode (matching actual pool files)
  DEFAULT_MATE_IN_ONE_PUZZLE_COUNTS = {
    (600..1000) => 20,
    (1000..1400) => 20,
    (1400..1800) => 20,
    (1800..2100) => 20,
    (2100..3200) => 20
  }.freeze

  # Create a fast mate-in-one level from theme pools
  def self.create_level_from_pools_fast(puzzle_counts: DEFAULT_MATE_IN_ONE_PUZZLE_COUNTS)
    # Randomly choose one color to move for the entire session
    color_to_move = %w[w b].sample
    
    # Use ThemedLevelCreator to get mate-in-one puzzles for the chosen color only
    puzzle_data = ThemedLevelCreator.create_theme_puzzle_set_fast_single_color(
      theme: "mateIn1",
      color_to_move: color_to_move,
      puzzle_counts: puzzle_counts,
      pools_dir: "data/themes/"
    )
    
    # Extract puzzle IDs from puzzle data
    puzzle_data.map { |puzzle| puzzle[:id] }.compact
  end

  # Create a mate-in-one level with full puzzle data
  def self.create_level_from_pools(puzzle_counts: DEFAULT_MATE_IN_ONE_PUZZLE_COUNTS)
    # Randomly choose one color to move for the entire session
    color_to_move = %w[w b].sample
    
    # Use ThemedLevelCreator to get mate-in-one puzzles for the chosen color only
    ThemedLevelCreator.create_theme_puzzle_set_fast_single_color(
      theme: "mateIn1",
      color_to_move: color_to_move,
      puzzle_counts: puzzle_counts,
      pools_dir: "data/themes/"
    )
  end

  # Export mate-in-one pools to files (if they don't exist)
  def self.export_pools_if_needed
    theme_dir = Rails.root.join("data/themes/mateIn1")
    
    unless Dir.exist?(theme_dir)
      puts "Mate-in-one theme pools don't exist. Creating them..."
      ThemedLevelCreator.export_theme_pools_to_files(theme: "mateIn1")
    end
  end
end
