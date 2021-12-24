# New lichess v2 puzzles
class LichessV2Puzzle < ActiveRecord::Base
  has_many :lichess_v2_puzzles_puzzle_sets
  has_many :puzzle_sets, through: :lichess_v2_puzzles_puzzle_sets

  before_save :calculate_lines_tree

  def is_reportable?
    false
  end

  def initial_move_uci
    moves_uci[0]
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
    # the 1st move sets up the puzzle FEN, the 2nd is the first player move
    self.moves_uci[1..-2].each_with_index do |move_uci, i|
      # go deeper in the tree to keep building it
      lines_tree[move_uci] = {}
      lines_tree = lines_tree[move_uci]
    end
    # treat the last move differently based on whether it's a checkmate puzzle
    last_move_uci = moves_uci[-1]
    if checkmate_puzzle?
      fen = initial_fen
      # get to the FEN just before the last player move of the puzzle
      self.moves_uci[..-2].each do |move_uci|
        fen = ChessJs.fen_after_move_uci(fen, move_uci)
      end
      # find moves from the last position of the puzzle that checkmate
      checkmate_moves_uci = ChessJs.checkmate_moves_uci_at_fen(fen)
      unless checkmate_moves_uci.include?(last_move_uci)
        # expect our calculated checkmate moves to include the one checkmate
        # move provided in the CSV
        throw "Expected #{moves_uci[-1]} to be in #{checkmate_moves_uci}"
      end
      # all moves that checkmate are winning moves of this puzzle
      checkmate_moves_uci.each do |checkmate_move_uci|
        lines_tree[checkmate_move_uci] = 'win'
      end
    else
      # there's only one valid last move in non-checkmate puzzles
      lines_tree[last_move_uci] = 'win'
    end
    self.lines_tree = lines_tree_root
  end

  # testing: for finding puzzles with multiple final player moves
  def self.dev_find_multi_solution
    found_puzzles = []
    LichessV2Puzzle.find_each do |p|
      next unless p.lines_tree.to_s.scan(/win/).length > 1
      next unless p.moves_uci.length > 8
      found_puzzles << p
      break if found_puzzles.length >= 5
    end
    found_puzzles
  end

  # Sorts puzzles by the order in which they show up in puzzle_ids
  def self.find_by_sorted(puzzle_ids)
    puzzle_ids = puzzle_ids.map(&:to_i)
    LichessV2Puzzle.where(id: puzzle_ids).sort_by { |p| puzzle_ids.index(p.id) }
  end

  def self.find_by_sorted_lichess(lichess_puzzle_ids)
    LichessV2Puzzle.where(puzzle_id: lichess_puzzle_ids).sort_by do |p|
      lichess_puzzle_ids.index(p.puzzle_id)
    end
  end
end
