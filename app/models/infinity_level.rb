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

  def add_puzzle(new_lichess_puzzle)
    puzzle = infinity_puzzles.create(data: new_lichess_puzzle.simplified_data)
    puzzle.id ? true : false
  end

  def puzzles_after_id(puzzle_id)
    if puzzle_id.nil?
      puzzles = infinity_puzzles
    else
      puzzles = infinity_puzzles.where('id > ?', puzzle_id)
    end
    puzzles.limit(10)
  end

  def first_puzzle
    infinity_puzzles.first
  end

  def last_puzzle
    infinity_puzzles.last
  end

  def num_puzzles
    @num_puzzles ||= infinity_puzzles.count
  end
end
