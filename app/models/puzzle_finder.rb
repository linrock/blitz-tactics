# Find all puzzles that use a particular id
#
class PuzzleFinder

  # For finding all instances of a lichess puzzle
  def self.find_by_lichess_puzzle_id(id)
    puzzles = []
    puzzles += CountdownPuzzle.where("(data ->> 'id')::int = ?", id).to_a
    puzzles += SpeedrunPuzzle.where("(data ->> 'id')::int = ?", id).to_a
    puzzles += InfinityPuzzle.where("(data ->> 'id')::int = ?", id).to_a
    puzzles += HastePuzzle.where("(data ->> 'id')::int = ?", id).to_a
    puzzles += RatedPuzzle.where("(data ->> 'id')::int = ?", id).to_a
    puzzles += RepetitionPuzzle.where("(data ->> 'id')::int = ?", id).to_a
    puzzles
  end
end
