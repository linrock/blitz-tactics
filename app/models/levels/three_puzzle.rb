# Three mode puzzle. Uses LichessV2Puzzle with specific filtering criteria
# and increasing difficulty progression.
#
# Filtering criteria:
# - popularity > 95
# - num_plays > 1000
# - Rating ranges: 600-800, 800-1000, 1000-1200, 1200-1400, 1400-1600, 1600-1800
# - All puzzles in a level must start with the same color to move (randomly chosen)

class ThreePuzzle

  # Rating ranges for difficulty progression (7 pools with ascending difficulty)
  RATING_RANGES = [
    (600..800),   # Pool 1: 600-800
    (800..1000),  # Pool 2: 800-1000
    (1000..1200), # Pool 3: 1000-1200
    (1200..1400), # Pool 4: 1200-1400
    (1400..1600), # Pool 5: 1400-1600
    (1600..1800), # Pool 6: 1600-1800
    (1800..2000)  # Pool 7: 1800-2000 (may have fewer puzzles)
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

  # Ultra-fast puzzle selection using single query with Ruby-side random sampling
  # Returns puzzles distributed across 7 rating range pools
  # All puzzles in a level must start with the same color to move
  def self.random_level(total_puzzles = 112)
    # Randomly choose between white to move and black to move
    color_to_move = %w(w b).sample
    puzzles_per_pool = 16  # 16 puzzles per pool = 112 total puzzles
    
    # Ultra-fast query with smart randomization
    # Use a random offset without counting (much faster!)
    random_offset = rand(10000)  # Start from a random position (up to 10k offset)
    
    all_puzzles_data = LichessV2Puzzle
      .where(popularity: 96..)  # popularity > 95
      .where(num_plays: 1001..) # num_plays > 1000
      .where(rating: 600..1800)  # All rating ranges
      .offset(random_offset)  # Start from a random position
      .limit(total_puzzles * 4)  # Get 4x what we need (reduced from 6x)
      .pluck(:puzzle_id, :initial_fen, :moves_uci, :lines_tree, :rating)
      .select { |puzzle_id, initial_fen, moves_uci, lines_tree, rating|
        # Filter by color using FEN string (6th field: "w" or "b")
        initial_fen.split(' ')[1] == color_to_move
      }
    
    # Group puzzles by rating range
    puzzles_by_range = Hash.new { |h, k| h[k] = [] }
    all_puzzles_data.each do |puzzle_data|
      puzzle_id, initial_fen, moves_uci, lines_tree, rating = puzzle_data
      
      # Find which rating range this puzzle belongs to
      range_index = RATING_RANGES.find_index { |range| range.include?(rating) }
      next unless range_index
      
      puzzles_by_range[range_index] << puzzle_data
    end
    
    # Randomly sample puzzles from each range
    selected_puzzles = []
    RATING_RANGES.each_with_index do |range, index|
      range_puzzles = puzzles_by_range[index] || []
      # Randomly sample puzzles_per_pool from this range
      selected_from_range = range_puzzles.sample(puzzles_per_pool)
      selected_puzzles.concat(selected_from_range)
    end
    
    # Convert to final format with rating preserved for sorting
    final_puzzles = selected_puzzles.first(total_puzzles).map { |puzzle_id, initial_fen, moves_uci, lines_tree, rating|
      # Convert UCI to SAN for the initial move
      initial_move_uci = moves_uci[0]
      begin
        move_obj = ChessJs.get_move_from_move_uci(initial_fen, initial_move_uci)
        initial_move_san = move_obj ? move_obj['san'] : initial_move_uci
      rescue => e
        Rails.logger.warn "Failed to convert UCI to SAN for puzzle #{puzzle_id}: #{e.message}"
        initial_move_san = initial_move_uci # Fallback to UCI
      end
      
      {
        id: puzzle_id,
        fen: initial_fen,
        lines: lines_tree,
        rating: rating,  # Keep rating for sorting
        initialMove: {
          san: initial_move_san,
          uci: initial_move_uci
        }
      }
    }
    
    # Sort by rating to maintain ascending difficulty
    # The randomization comes from: 1) random offset, 2) random sampling within pools
    final_puzzles.sort_by { |puzzle| puzzle[:rating] }
  end

end