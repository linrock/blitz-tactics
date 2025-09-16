# Three mode puzzle. Uses precomputed text files from game-modes/three/
# for ultra-fast puzzle selection with increasing difficulty progression.
#
# Features:
# - Uses text files created by ThreeLevelCreator
# - 10 pools per color (20 total pools)
# - Rating ranges: 600-800, 800-1000, ..., 2000-2100
# - All puzzles in a level must start with the same color to move (randomly chosen)
# - 10 puzzles from each pool = 100 total puzzles by default

class ThreePuzzle

  # Pool configuration matching ThreeLevelCreator
  POOLS_PER_COLOR = 10
  PUZZLES_PER_POOL = 10
  DEFAULT_TOTAL_PUZZLES = 100

  # Get a random easy puzzle to show on the homepage
  def self.random
    # Load from the easiest white pool
    puzzle_ids = load_pool_ids('w', 1)
    return nil if puzzle_ids.empty?
    
    puzzle_id = puzzle_ids.sample
    LichessV2Puzzle.find_by(puzzle_id: puzzle_id)
  end

  # Create a random level using text files
  # Returns puzzles distributed across 10 rating range pools
  # All puzzles in a level must start with the same color to move
  def self.random_level(total_puzzles = DEFAULT_TOTAL_PUZZLES)
    # Randomly choose between white to move and black to move
    color_to_move = %w(w b).sample
    puzzles_per_pool = total_puzzles / POOLS_PER_COLOR
    
    selected_puzzle_ids = []
    
    # Get 10 puzzles from each of the 10 pools for the chosen color
    (1..POOLS_PER_COLOR).each do |pool_number|
      pool_ids = load_pool_ids(color_to_move, pool_number)
      next if pool_ids.empty?
      
      # Randomly sample puzzles from this pool
      selected_from_pool = pool_ids.sample(puzzles_per_pool)
      selected_puzzle_ids.concat(selected_from_pool)
    end
    
    # Fetch puzzle data from database
    puzzles = LichessV2Puzzle.where(puzzle_id: selected_puzzle_ids)
    
    # Convert to blitz tactics format with rating included
    puzzles.map do |puzzle|
      puzzle_data = puzzle.bt_puzzle_data
      puzzle_data[:rating] = puzzle.rating  # Add rating for sorting
      puzzle_data
    end.sort_by { |puzzle| puzzle[:rating] || 0 }
  end

  private

  # Load puzzle IDs from a specific pool text file
  def self.load_pool_ids(color_to_move, pool_number)
    filename = "#{color_to_move}_pool_#{pool_number}_*.txt"
    file_path = Rails.root.join("data", "game-modes", "three", filename)
    
    # Find the actual file (since we don't know the exact rating range in filename)
    actual_file = Dir.glob(file_path).first
    return [] unless actual_file && File.exist?(actual_file)
    
    # Read puzzle IDs from file (one per line)
    File.readlines(actual_file).map(&:strip).reject(&:empty?)
  rescue => e
    Rails.logger.warn "Failed to load pool #{color_to_move}_#{pool_number}: #{e.message}"
    []
  end

end