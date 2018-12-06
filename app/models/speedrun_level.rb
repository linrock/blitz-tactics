class SpeedrunLevel < ActiveRecord::Base
  NAMES = %w( quick endurance marathon )

  has_many :speedrun_puzzles, dependent: :destroy
  has_many :completed_speedruns, dependent: :destroy

  validates :name,
    presence: true,
    uniqueness: true

  NAMES.each do |name|
    scope name, -> { find_or_create_by(name: name) }
  end

  def self.today
    Date.today
  end

  def self.todays_date
    today.strftime "%b %-d, %Y"
  end

  def self.todays_level
    find_by(name: today.to_s)
  end

  def self.first_level
    find_by(name: 'quick')
  end

  def puzzles
    speedrun_puzzles.order('id ASC')
  end

  def first_puzzle
    puzzles.first
  end

  # fastest 5 first speedruns for this level
  def fastest_first_speedruns
    first_runs = completed_speedruns.group(:user_id).minimum(:id).values
    top_5 = completed_speedruns.where(id: first_runs).order(elapsed_time_ms: :asc).limit(5)
    top_5
  end

  # fastest overall speedruns for this level
  def fastest_speedruns
    first_runs = completed_speedruns.group(:user_id).minimum(:id).values
    top_5 = completed_speedruns.where(id: first_runs).order(elapsed_time_ms: :asc).limit(5)
    top_5
  end

  def num_puzzles
    @num_puzzles ||= speedrun_puzzles.count
  end
end
