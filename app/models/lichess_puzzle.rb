# New lichess v2 puzzles
class LichessPuzzle < ActiveRecord::Base

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

  # converts an array of puzzle moves to old tree format
  def lines_tree
    lines_tree_root = {}
    lines_tree = lines_tree_root
    last_move_uci = nil
    moves_uci[1..].each do |move_uci|
      lines_tree[move_uci] = {}
      lines_tree = lines_tree[move_uci]
      last_move_uci = move_uci
    end
    lines_tree[last_move_uci] = 'win'
    lines_tree_root
  end
end
