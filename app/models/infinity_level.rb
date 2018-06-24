# puzzle_id_array = ordered list of puzzle ids
# puzzle_id_map = map of new lichess puzzle ids (puzzle.id) => { p: prev_id, n: next_id }

class InfinityLevel < ActiveRecord::Base
  DIFFICULTIES = %w( easy medium hard insane )

  has_many :infinity_puzzles, dependent: :destroy

  validates :difficulty,
    presence: true,
    uniqueness: true,
    inclusion: DIFFICULTIES

  DIFFICULTIES.each do |difficulty|
    scope difficulty, -> { find_or_create_by(difficulty: difficulty) }
  end

  def first_puzzle
    infinity_puzzles.first
  end

  def new_lichess_puzzles_after(new_lichess_puzzle_id) # Array<NewLichessPuzzle>
    if new_lichess_puzzle_id.nil?
      puzzles = infinity_puzzles
    else
      puzzle = infinity_puzzles.find_by(
        new_lichess_puzzle_id: new_lichess_puzzle_id
      )
      if puzzle
        puzzles = infinity_puzzles.where('index > ?', puzzle.index)
      else
        return []
      end
    end
    puzzles.limit(10).includes(:new_lichess_puzzle).map(&:puzzle)
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

  def last_puzzle
    infinity_puzzles.last
  end

  def last_puzzle_index
    last_puzzle&.index || -1
  end

  def num_puzzles
    @num_puzzles ||= infinity_puzzles.count
  end
end
