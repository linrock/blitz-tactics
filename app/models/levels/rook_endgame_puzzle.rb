# Rook endgame mode puzzle using the ThemedLevelCreator system
# Uses ThemedLevelCreator for rook endgame puzzle generation

class RookEndgamePuzzle
  # Default puzzle counts for rook endgame mode (matching theme pool files)
  DEFAULT_ROOK_ENDGAME_PUZZLE_COUNTS = {
    (600..1000) => 10,
    (1000..1400) => 25,
    (1400..1800) => 30,
    (1800..2100) => 25,
    (2100..3200) => 10,
  }.freeze

  # Get a random easy rook endgame puzzle to show on the homepage
  def self.random
    # Get a random puzzle from the easiest pool file (600-1000 rating range)
    pools_dir = "data/themes/rookEndgame/"
   
    # Randomly choose a color for the easiest pool
    color = %w[w b].sample
    filename = "#{color}_pool_01_600-1000.txt"
    file_path = Rails.root.join(pools_dir, filename)
    
    if File.exist?(file_path)
      pool_puzzle_data = File.readlines(file_path).map(&:strip).reject(&:empty?)
      if pool_puzzle_data.any?
        # Pick a random puzzle from the easiest pool
        random_line = pool_puzzle_data.sample
        puzzle_id = random_line.split("|", 3)[0] # Get puzzle_id
        return LichessV2Puzzle.find_by(puzzle_id: puzzle_id)
      end
    end

    # Fallback: return nil if no pool files exist
    nil
  end

  # Create a random level using ThemedLevelCreator
  def self.random_level(total_puzzles = 100)
    # Randomly choose a color to move for the entire puzzle set
    color_to_move = %w[w b].sample
    
    # Use ThemedLevelCreator to generate puzzle data with consistent color
    puzzle_data = ThemedLevelCreator.create_theme_puzzle_set_fast_single_color(
      theme: "rookEndgame",
      color_to_move: color_to_move,
      puzzle_counts: DEFAULT_ROOK_ENDGAME_PUZZLE_COUNTS,
      pools_dir: "data/themes/"
    )
    
    # Sort puzzles by rating
    puzzle_data.sort_by { |puzzle| puzzle[:rating] || 0 }
  end
end