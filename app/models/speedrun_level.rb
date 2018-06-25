class SpeedrunLevel < ActiveRecord::Base
  NAMES = %w( quick endurance marathon )

  has_many :speedrun_puzzles, dependent: :destroy

  validates :name,
    presence: true,
    uniqueness: true,
    inclusion: NAMES

  NAMES.each do |name|
    scope name, -> { find_or_create_by(name: name) }
  end

  def self.first_level
    find_by(name: 'quick')
  end

  def self.first_puzzle
    first_level.first_puzzle
  end

  def first_puzzle
    speedrun_puzzles.first
  end

  def num_puzzles
    @num_puzzles ||= speedrun_puzzles.count
  end
end
