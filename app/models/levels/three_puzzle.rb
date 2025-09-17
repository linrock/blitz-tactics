# Three mode puzzle using the LevelCreator system
# Uses LevelCreator.create_level_from_pools for level generation

# Temporary model to access old haste_puzzles table
class HastePuzzleOld < ActiveRecord::Base
  self.table_name = 'haste_puzzles'
end

class ThreePuzzle
  # Get a random easy puzzle to show on the homepage
  def self.random
    # Get a random puzzle from the easiest pool file (600-800 rating range)
    pools_dir = "data/puzzle-pools/"
    
    # Randomly choose a color for the easiest pool
    color = %w[w b].sample
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
    
    # Fallback: use old haste_puzzles table if pool files don't exist
    old_haste_puzzle = HastePuzzleOld.where(difficulty: 0).order(Arel.sql('RANDOM()')).first
    if old_haste_puzzle
      # Convert old format to LichessV2Puzzle format
      puzzle_data = old_haste_puzzle.data
      puzzle = LichessV2Puzzle.new(
        puzzle_id: puzzle_data["id"],
        initial_fen: puzzle_data["fen"],
        moves_uci: [puzzle_data["initialMove"]["uci"]],
        themes: [],
        rating: 600, # Default rating for old puzzles
        popularity: 95,
        num_plays: 1000
      )
      # Pre-compute SAN to avoid ChessJs calls
      puzzle.instance_variable_set(:@initial_move_san, puzzle_data["initialMove"]["san"])
      puzzle
    else
      nil
    end
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