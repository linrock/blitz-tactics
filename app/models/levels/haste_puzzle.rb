# Haste mode puzzle using the LevelCreator system
# Uses LevelCreator.create_level_from_pools for level generation

class HastePuzzle
  # Get a random easy puzzle to show on the homepage
  def self.random
    # Get a random puzzle from the easiest pool file (600-800 rating range)
    pools_dir = "data/puzzle-pools/"
    
    # Try both colors for the easiest pool
    %w[w b].each do |color|
      filename = "#{color}_pool_01_600-800.txt"
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
    end
    
    # Fallback: database query if pool files don't exist
    LichessV2Puzzle
      .where(popularity: 95..)
      .where(num_plays: 1000..)
      .where(rating: 600..800)
      .order(Arel.sql('RANDOM()'))
      .first
  end

  # Create a random level using LevelCreator
  def self.random_level(total_puzzles = 100)
    # Use LevelCreator to generate puzzle IDs
    puzzle_ids = LevelCreator.create_level_from_pools_fast
    
    # Convert puzzle IDs to LichessV2Puzzle objects and format them
    puzzles = LichessV2Puzzle.where(puzzle_id: puzzle_ids)
    
    puzzles.map do |puzzle|
      puzzle_data = puzzle.bt_puzzle_data
      puzzle_data[:rating] = puzzle.rating
      puzzle_data
    end.sort_by { |puzzle| puzzle[:rating] || 0 }
  end
end
