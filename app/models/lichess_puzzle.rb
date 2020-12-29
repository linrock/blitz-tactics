# New lichess v2 puzzles
class LichessPuzzle < ActiveRecord::Base

  def is_reportable?
    false
  end

  def puzzle_data
    lines_tree_root = {}
    lines = lines_tree_root
    last_move_uci = nil
    moves_uci[1..].each do |move_uci|
      lines[move_uci] = {}
      lines = lines[move_uci]
      last_move_uci = move_uci
    end
    lines[last_move_uci] = 'win'
    {
      initial_fen: initial_fen,
      initial_move_uci: moves_uci[0],
      lines: lines_tree_root,
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
end
