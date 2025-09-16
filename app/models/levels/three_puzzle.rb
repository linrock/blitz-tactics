# Three mode puzzle. Uses LichessV2Puzzle with specific filtering criteria
# and increasing difficulty progression.
#
# Filtering criteria:
# - popularity > 95
# - num_plays > 1000
# - Rating ranges: 600-800, 800-1000, 1000-1200, 1200-1400, 1400-1600, 1600-1800
# - All puzzles in a level must start with the same color to move (randomly chosen)

class ThreePuzzle

  # Rating ranges for difficulty progression (6 sections as specified)
  RATING_RANGES = [
    (600..800),
    (800..1000),
    (1000..1200),
    (1200..1400),
    (1400..1600),
    (1600..1800)
  ].freeze

  # Get a random easy puzzle to show on the homepage
  def self.random
    LichessV2Puzzle
      .where(popularity: 96..)
      .where(num_plays: 1001..)
      .where(rating: 600..800)  # Easy rating range
      .order(Arel.sql('RANDOM()'))
      .first
  end

  # Random set of puzzles with increasing difficulty
  # All puzzles in a level must start with the same color to move
  def self.random_level(n)
    # Randomly choose between white to move and black to move
    color_to_move = %w(w b).sample
    
    # Single optimized query using a more efficient approach
    # Get a larger sample and then distribute by rating ranges in Ruby
    # This is much faster than multiple database queries
    
    # Get a large sample of puzzles that match our criteria
    # We'll get more than needed and then distribute by rating ranges
    sample_size = n * 3 # Get 3x more than needed for better distribution
    
    all_puzzles = LichessV2Puzzle
      .where(popularity: 96..)  # popularity > 95
      .where(num_plays: 1001..) # num_plays > 1000
      .where("initial_fen LIKE ?", "% #{color_to_move} %")  # same color to move
      .order(Arel.sql('RANDOM()'))
      .limit(sample_size)
      .to_a
    
    # Group puzzles by rating range
    puzzles_by_range = RATING_RANGES.map.with_index do |rating_range, index|
      range_puzzles = all_puzzles.select { |p| rating_range.cover?(p.rating) }
      # Take up to 7 puzzles from each range, or all if less than 7
      range_puzzles.sample([7, range_puzzles.size].min)
    end.flatten
    
    # If we need more puzzles, add more from the highest rating range
    if puzzles_by_range.length < n
      remaining_needed = n - puzzles_by_range.length
      highest_range_puzzles = all_puzzles.select { |p| (1600..1800).cover?(p.rating) }
      additional_puzzles = highest_range_puzzles.sample(remaining_needed)
      puzzles_by_range.concat(additional_puzzles)
    end
    
    # Limit to requested number and ensure we have enough
    puzzles = puzzles_by_range.first(n)
    
    # If we still don't have enough, get more from any rating range
    if puzzles.length < n
      remaining_needed = n - puzzles.length
      additional_puzzles = all_puzzles.sample(remaining_needed)
      puzzles.concat(additional_puzzles)
    end
    
    # Convert to the expected format efficiently
    puzzles.map do |lichess_puzzle|
      begin
        # Convert UCI move to chess.js move object to get proper SAN
        move_obj = ChessJs.get_move_from_move_uci(lichess_puzzle.initial_fen, lichess_puzzle.initial_move_uci)
        
        {
          id: lichess_puzzle.puzzle_id.to_i,
          fen: lichess_puzzle.initial_fen,
          lines: lichess_puzzle.lines_tree,
          initialMove: {
            san: move_obj["san"],
            uci: lichess_puzzle.initial_move_uci
          }
        }
      rescue => e
        # Fallback: if move conversion fails, use UCI as SAN (temporary fix)
        Rails.logger.warn "Failed to convert move for puzzle #{lichess_puzzle.puzzle_id}: #{e.message}. Using UCI as SAN."
        {
          id: lichess_puzzle.puzzle_id.to_i,
          fen: lichess_puzzle.initial_fen,
          lines: lichess_puzzle.lines_tree,
          initialMove: {
            san: lichess_puzzle.initial_move_uci, # Fallback to UCI
            uci: lichess_puzzle.initial_move_uci
          }
        }
      end
    end
  end
end