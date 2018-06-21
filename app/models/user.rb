class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :validatable,
  # :recoverable, and :omniauthable

  devise :database_authenticatable, :registerable, :rememberable,
         :trackable, :validatable

  has_many :level_attempts
  has_many :solved_infinity_puzzles
  has_many :positions

  after_initialize :set_default_profile

  validate :validate_username

  # infinity puzzle methods

  def latest_difficulty
    solved_infinity_puzzles.last&.difficulty || 'easy'
  end

  def new_lichess_puzzles_after(difficulty, new_lichess_puzzle_id)
    InfinityLevel
      .find_by(difficulty: difficulty)
      .new_lichess_puzzles_after(
        new_lichess_puzzle_id || last_solved_infinity_puzzle_id(difficulty)
      )
  end

  def last_solved_infinity_puzzle_id(difficulty)
    solved_infinity_puzzles
      .with_difficulty(difficulty).last&.new_lichess_puzzle_id
  end

  def next_infinity_puzzle
    new_lichess_puzzles_after(
      latest_difficulty,
      last_solved_infinity_puzzle_id(latest_difficulty)
    ).first
  end

  def num_infinity_puzzles_solved
    solved_infinity_puzzles.count
  end

  # repetition mode methods

  def unlock_level(level_id)
    level_ids = Set.new(self.profile["levels_unlocked"])
    level_ids << level_id
    self.profile["levels_unlocked"] = level_ids.to_a
    self.save!
  end

  def unlocked_levels
    Set.new(self.profile["levels_unlocked"])
  end

  def highest_level_unlocked
    Level.find_by(id: self.profile["levels_unlocked"].max)
  end

  def unlocked_sequential_levels?
    unlocked_levels.size == highest_level_unlocked
  end

  def unlocked_all_levels?
    highest_level_unlocked == 65
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
