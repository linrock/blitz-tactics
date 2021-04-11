class User < ActiveRecord::Base
  include UserDelegates

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :validatable,
  # :recoverable, and :omniauthable

  devise :database_authenticatable, :registerable, :rememberable,
         :trackable, :validatable, :recoverable

  has_many :level_attempts
  has_many :solved_infinity_puzzles
  has_many :completed_speedruns
  has_many :completed_countdown_levels
  has_many :completed_haste_rounds
  has_many :completed_three_rounds
  has_many :completed_repetition_rounds
  has_many :completed_repetition_levels
  has_many :positions

  has_one :user_chessboard
  has_one :user_rating

  after_initialize :set_default_profile

  before_validation :nullify_blank_email
  validates :email, uniqueness: true, allow_blank: true
  validate :validate_username

  # for devise to case-insensitively find users by username
  def self.find_for_database_authentication(conditions)
    if conditions.has_key?(:username)
      username = conditions[:username].downcase
      where("LOWER(username) = ?", username).first
    end
  end

  # infinity puzzle methods

  def num_infinity_puzzles_solved
    @num_infinity_puzzles_solved ||= solved_infinity_puzzles.count
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
    SpeedrunLevel.where(id: level_ids).order('id DESC').map do |level|
      next if level.name == "quick"
      [
        level.name,
        completed_speedruns.formatted_personal_best(level.id)
      ]
    end.compact.sort_by {|name, time| name }.reverse
  end

  # haste mode methods

  def haste_round_high_score(date)
    completed_haste_rounds.personal_best(date)
  end

  def num_haste_rounds_completed
    @num_haste_rounds_completed ||= completed_haste_rounds.count
  end

  # three mode methods

  def num_three_rounds_completed
    @num_three_rounds_completed ||= completed_three_rounds.count
  end

  # countdown mode methods

  def num_countdowns_completed
    @num_countdowns_completed ||= completed_countdown_levels.count
  end

  def countdown_stats
    level_ids = completed_countdown_levels.pluck(Arel.sql('distinct(countdown_level_id)'))
    CountdownLevel.where(id: level_ids).order('id DESC').map do |level|
      [
        level.name,
        completed_countdown_levels.personal_best(level.id)
      ]
    end.sort_by {|name, time| name }.reverse
  end

  # old repetition mode methods

  def hall_of_famer?
    return false unless self.profile["levels_unlocked"]
    Set.new(self.profile["levels_unlocked"]).count == 65
  end

  # new repetition mode methods

  def repetition_stats
    fastest_laps = completed_repetition_rounds
      .group(:repetition_level_id)
      .minimum(:elapsed_time_ms)
      .map do |repetition_level_id, elapsed_time_ms|
        [
          RepetitionLevel.find_by(id: repetition_level_id),
          Time.at(elapsed_time_ms / 1000).strftime("%M:%S").gsub(/^0/, '')
        ]
      end.sort_by {|level, _| level.number }
  end

  def highest_repetition_level_number_completed
    @highest_repetition_level_number_completed ||= completed_repetition_levels
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


  def completed_repetition_level?(repetition_level_id)
    completed_repetition_rounds
      .where(repetition_level_id: repetition_level_id)
      .count > 0
  end

  def num_repetition_levels_completed
    @num_repetition_levels_completed ||= completed_repetition_levels.count
  end

  # user puzzle stats

  def recent_high_scores?
    num_countdowns_completed > 0 or num_speedruns_completed
  end

  def all_time_high_scores?
    recent_high_scores? \
      or num_repetition_levels_completed > 0 \
      or num_infinity_puzzles_solved > 0
  end

  # user settings

  def set_sound_enabled(enabled)
    self.profile["sound_enabled"] = enabled
    self.save!
  end

  def sound_enabled?
    !!self.profile["sound_enabled"]
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
