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

  def puzzles_after_id(puzzle_id)
    if puzzle_id.nil?
      puzzles = infinity_puzzles
    else
      puzzles = infinity_puzzles.where('id > ?', puzzle_id)
    end
    puzzles.limit(10)
  end

  def first_puzzle
    infinity_puzzles.order('id ASC').first
  end

  def last_puzzle
    infinity_puzzles.order('id DESC').last
  end

  def random_puzzle_id
    min_puzzle_id = infinity_puzzles.minimum(:id)
    max_puzzle_id = infinity_puzzles.maximum(:id) - 100
    min_puzzle_id + (rand * max_puzzle_id).to_i
  end

  def num_puzzles
    @num_puzzles ||= infinity_puzzles.count
  end
end
