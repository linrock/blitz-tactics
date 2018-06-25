class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :validatable,
  # :recoverable, and :omniauthable

  devise :database_authenticatable, :registerable, :rememberable,
         :trackable, :validatable

  has_many :level_attempts
  has_many :solved_infinity_puzzles
  has_many :completed_speedruns
  has_many :positions

  after_initialize :set_default_profile

  validate :validate_username

  # infinity puzzle methods

  def latest_difficulty
    solved_infinity_puzzles.last&.difficulty || 'easy'
  end

  def infinity_puzzles_after(difficulty, puzzle_id)
    InfinityLevel
      .find_by(difficulty: difficulty)
      .puzzles_after_id(puzzle_id || last_solved_infinity_puzzle_id(difficulty))
  end

  def last_solved_infinity_puzzle_id(difficulty)
    solved_infinity_puzzles.with_difficulty(difficulty).last&.infinity_puzzle_id
  end

  def next_infinity_puzzle
    infinity_puzzles_after(
      latest_difficulty,
      last_solved_infinity_puzzle_id(latest_difficulty)
    ).first || InfinityLevel.find_by(difficulty: latest_difficulty).last_puzzle
  end

  def num_infinity_puzzles_solved
    solved_infinity_puzzles.count
  end

  def infinity_puzzles_solved_by_difficulty
    InfinityLevel::DIFFICULTIES.map do |difficulty|
      [
        difficulty,
        solved_infinity_puzzles.where(difficulty: difficulty).count
      ]
    end
  end

  # speedrun mode methods
  def num_speedruns_completed
    @num_speedruns_completed ||= completed_speedruns.count
  end

  def best_speedrun_time
    completed_speedruns.formatted_fastest_time
  end

  def speedrun_stats
    SpeedrunLevel.all.map do |level|
      [
        level.name,
        completed_speedruns.formatted_personal_best(level.id)
      ]
    end
  end

  # repetition mode methods

  def unlocked_level_numbers
    Set.new(self.profile["levels_unlocked"])
  end

  def unlock_level(level_number)
    level_nums = unlocked_level_numbers
    level_nums << level_number
    self.profile["levels_unlocked"] = level_nums.to_a
    self.save!
  end

  def num_repetition_levels_unlocked
    unlocked_level_numbers.count
  end

  def highest_level_unlocked
    level = Level.by_number(unlocked_level_numbers.max)
    return level if level.present?
    Level.by_number(1)
  end

  def unlocked_all_levels?
    num_repetition_levels_unlocked == Level.count
  end

  def round_times_for_level(level_id)
    attempt = level_attempts.find_by_id(level_id)
    return [] unless attempt
    rounds = attempt.completed_rounds.order("id DESC")
    rounds.map(&:formatted_time_spent)
  end

  def self.find_for_database_authentication(conditions)
    if conditions.has_key?(:username)
      username = conditions[:username].downcase
      where("LOWER(username) = ?", username).first
    end
  end

  private

  def email_required?
    false
  end

  def set_default_profile
    self.profile ||= {
      "levels_unlocked": [1]
    }
  end

  def validate_username
    unless username =~ /\A[a-z]/i
      errors.add :username, "must start with a letter"
    end
    unless username =~ /\A[a-z][a-z0-9_]{2,}\Z/i
      errors.add :username, "must be at least 3 letters, numbers, or underscores"
    end
    if username.length > 32
      errors.add :username, "is too long"
    end
    return unless new_record?
    if User.where("LOWER(username) = ?", username.downcase).count > 0
      errors.add :username, "is already registered"
    end
  end
end
