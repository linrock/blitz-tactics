class User < ActiveRecord::Base
  include UserDelegates

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :validatable,
  # :recoverable, and :omniauthable

  devise :database_authenticatable, :registerable, :rememberable,
         :trackable, :validatable

  has_many :level_attempts
  has_many :solved_infinity_puzzles
  has_many :completed_speedruns
  has_many :completed_repetition_rounds
  has_many :completed_repetition_levels
  has_many :positions

  after_initialize :set_default_profile

  before_validation :nullify_blank_email
  validates :email, uniqueness: true, allow_blank: true
  validate :validate_username

  def self.old_scoreboard_ranks(n)
    all.sort_by { |user| -user.num_repetition_levels_unlocked }.take(n)
  end

  def self.all_repetition_levels_unlocked
    all.select {|u| u.num_repetition_levels_unlocked == RepetitionLevel.count }
  end

  # for devise to case-insensitively find users by username
  def self.find_for_database_authentication(conditions)
    if conditions.has_key?(:username)
      username = conditions[:username].downcase
      where("LOWER(username) = ?", username).first
    end
  end

  # infinity puzzle methods

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

  def speedrun_stats
    level_ids = completed_speedruns.pluck(Arel.sql('distinct(speedrun_level_id)'))
    SpeedrunLevel.where(id: level_ids).order('id ASC').map do |level|
      [
        level.name,
        completed_speedruns.formatted_personal_best(level.id)
      ]
    end
  end

  # old repetition mode methods

  def num_repetition_levels_unlocked
    Set.new(self.profile["levels_unlocked"]).count
  end

  # new repetition mode methods

  def highest_repetition_level_number_completed
    completed_repetition_levels
      .includes(:repetition_level)
      .joins(:repetition_level)
      .order('repetition_levels.number desc')
      .first&.repetition_level&.number || 0
  end

  def round_times_for_level_id(repetition_level_id)
    completed_repetition_rounds
      .where(repetition_level_id: repetition_level_id)
      .order(id: :desc)
      .limit(10)
      .map(&:formatted_time_spent)
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

  def nullify_blank_email
    self.email = nil if self.email.blank?
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
