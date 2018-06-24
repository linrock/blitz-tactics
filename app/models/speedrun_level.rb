class SpeedrunLevel < ActiveRecord::Base
  NAMES = %w( quick endurance marathon )

  has_many :speedrun_puzzles, dependent: :destroy

  def self.first_level
    find_by(name: 'quick')
  end

  def self.first_puzzle
    first_level.first_puzzle
  end

  def add_puzzle(new_lichess_puzzle)
    return false if speedrun_puzzles.exists?(
      new_lichess_puzzle_id: new_lichess_puzzle.id
    )
    speedrun_puzzles.create!({
      new_lichess_puzzle_id: new_lichess_puzzle.id
    })
  end

  def first_puzzle
    speedrun_puzzles.first
  end

  def num_puzzles
    @num_puzzles ||= speedrun_puzzles.count
  end
end
