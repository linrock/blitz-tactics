# New lichess v2 puzzles
class LichessV2Puzzle < ActiveRecord::Base
  before_save :calculate_lines_tree

  def is_reportable?
    false
  end

  # puzzle format used by blitz tactics game modes
  def bt_puzzle_data
    # TODO clean this up
    {
      id: puzzle_id,
      fen: initial_fen,
      lines: lines_tree,
      initialMove: {
        uci: moves_uci[0],
      }
    }
  end

  # data format used by puzzle pages
  def puzzle_data
    {
      initial_fen: initial_fen,
      initial_move_uci: moves_uci[0],
      lines: lines_tree,
    }
  end

  def metadata
    {
      rating: rating,
      rating_deviation: rating_deviation,
      popularity: popularity,
      num_plays: num_plays,
      themes: themes,
    }
  end

  def as_json(options={})
    {
      puzzle_data: puzzle_data,
      metadata: metadata,
    }
  end

  private

  def checkmate_puzzle?
    themes.include?("mate")
  end

  # converts an array of puzzle moves to old lines tree format
  def calculate_lines_tree
    lines_tree_root = {}
    lines_tree = lines_tree_root
    last_move_uci = nil
    self.moves_uci[1..].each do |move_uci|
      lines_tree[move_uci] = {}
      lines_tree = lines_tree[move_uci]
      last_move_uci = move_uci
    end
    lines_tree[last_move_uci] = 'win'
    if checkmate_puzzle?
      fen = initial_fen
      self.moves_uci[..-2].each do |move_uci|
        fen = ChessJS.fen_after_move_uci(fen, move_uci)
      end
      # moves from the last position of the puzzle that checkmate
      checkmate_moves_uci = ChessJS.checkmate_moves_uci_at_fen(fen)
      unless checkmate_moves_uci.include?(moves_uci[-1])
        # expect our calculated checkmate moves to include the one checkmate
        # move provided in the CSV
        throw "Expected #{moves_uci[-1]} to be in #{checkmate_moves_uci}"
      end
      checkmate_moves_uci.each do |checkmate_move_uci|
        # all moves that checkmate are winning moves of this puzzle
        lines_tree[checkmate_move_uci] = 'win'
      end
    end
    lines_tree_root
    self.lines_tree = lines_tree_root
  end
end
