# puzzle_id_array = ordered list of puzzle ids
# puzzle_id_map = map of new lichess puzzle ids (puzzle.id) => { p: prev_id, n: next_id }

class InfinityLevel < ActiveRecord::Base
  has_many :infinity_puzzles

  validates :difficulty,
    presence: true,
    uniqueness: true,
    inclusion: %w( easy medium hard insane )

  def first_puzzle
    infinity_puzzles.first
  end

  def new_lichess_puzzles_after(new_lichess_puzzle_id) # Array<NewLichessPuzzle>
    if new_lichess_puzzle_id.nil?
      infinity_puzzles.limit(10)
    else
      puzzle = infinity_puzzles.find_by(
        new_lichess_puzzle_id: new_lichess_puzzle_id
      )
      infinity_puzzles.where('index > ?', puzzle.index).limit(10)
    end.includes(:new_lichess_puzzle).map(&:puzzle)
  end

  def add_puzzle(new_lichess_puzzle)
    return false if infinity_puzzles.exists?(
      new_lichess_puzzle_id: new_lichess_puzzle.id
    )
    infinity_puzzles.create!({
      index: last_puzzle_index + 1,
      new_lichess_puzzle_id: new_lichess_puzzle.id
    })
  end

  def last_puzzle_index
    infinity_puzzles.last&.index || -1
  end
end
