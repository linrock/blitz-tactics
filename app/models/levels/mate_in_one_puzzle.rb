# Mate-in-one mode puzzle using the ThemedLevelCreator system
# Uses ThemedLevelCreator for mate-in-one puzzle generation

class MateInOnePuzzle
  # Get a random easy mate-in-one puzzle to show on the homepage
  def self.random
    # Get a random puzzle from the easiest mate-in-one pool file (600-800 rating range)
    pools_dir = "data/themes/mateIn1/"
   
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

    # Fallback: use a random mate-in-one puzzle from database
    mate_puzzle = LichessV2Puzzle.where("themes @> ?", "{mateIn1}")
                                 .where(rating: 600..1000)
                                 .order(Arel.sql('RANDOM()'))
                                 .first
    if mate_puzzle
      mate_puzzle
    else
      nil
    end
  end

  # Create a random level using MateInOneLevelCreator for mate-in-one puzzles
  def self.random_level(total_puzzles = 100)
    # Use MateInOneLevelCreator to generate mate-in-one puzzle IDs
    puzzle_ids = MateInOneLevelCreator.create_level_from_pools_fast
    
    # Convert puzzle IDs to LichessV2Puzzle objects and format them
    puzzles = LichessV2Puzzle.where(puzzle_id: puzzle_ids)
    
    puzzles.map do |puzzle|
      puzzle_data = puzzle.bt_puzzle_data
      puzzle_data[:rating] = puzzle.rating
      puzzle_data
    end.sort_by { |puzzle| puzzle[:rating] || 0 }
  end
end
