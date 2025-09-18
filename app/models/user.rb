class User < ActiveRecord::Base
  include UserDelegates

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :validatable,
  # :recoverable, and :omniauthable

  devise :database_authenticatable, :registerable, :rememberable,
         :trackable, :validatable, :recoverable

  has_many :level_attempts
  has_many :puzzle_sets
  has_many :solved_infinity_puzzles
  has_many :completed_speedruns
  has_many :completed_countdown_levels
  has_many :completed_haste_rounds
  has_many :completed_mate_in_one_rounds
  has_many :completed_rook_endgames_rounds
  has_many :completed_three_rounds
  has_many :completed_repetition_rounds
  has_many :completed_openings_rounds
  has_many :completed_repetition_levels
  has_many :positions
  has_many :completed_quest_world_levels
  has_many :completed_quest_worlds
  has_many :solved_puzzles, counter_cache: :solved_puzzles_count
  
  # Quest-related helper methods
  def completed_quest_world?(world)
    completed_quest_worlds.exists?(quest_world: world)
  end
  
  def completed_quest_world_level?(level)
    completed_quest_world_levels.exists?(quest_world_level: level)
  end
  
  def quest_world_completion_percentage(world)
    world.completion_percentage(self)
  end

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
    SpeedrunLevel.where(id: level_ids).order('name DESC').map do |level|
      next if level.name == "quick"
      [
        format_level_date(level.name),
        completed_speedruns.formatted_personal_best(level.id)
      ]
    end.compact
  end

  # haste mode methods

  def haste_round_high_score(date)
    completed_haste_rounds.personal_best(date)
  end

  def num_haste_rounds_completed
    @num_haste_rounds_completed ||= completed_haste_rounds.count
  end

  # mate-in-one mode methods

  def mate_in_one_round_high_score(date)
    completed_mate_in_one_rounds.personal_best(date)
  end

  def num_mate_in_one_rounds_completed
    @num_mate_in_one_rounds_completed ||= completed_mate_in_one_rounds.count
  end

  # rook endgames mode methods

  def rook_endgames_round_high_score(date)
    completed_rook_endgames_rounds.personal_best(date)
  end

  def num_rook_endgames_rounds_completed
    @num_rook_endgames_rounds_completed ||= completed_rook_endgames_rounds.count
  end

  # three mode methods

  def num_three_rounds_completed
    @num_three_rounds_completed ||= completed_three_rounds.count
  end

  def num_openings_rounds_completed
    @num_openings_rounds_completed ||= completed_openings_rounds.count
  end

  # countdown mode methods

  def num_countdowns_completed
    @num_countdowns_completed ||= completed_countdown_levels.count
  end

  def countdown_stats
    level_ids = completed_countdown_levels.pluck(Arel.sql('distinct(countdown_level_id)'))
    CountdownLevel.where(id: level_ids).order('name DESC').map do |level|
      [
        format_level_date(level.name),
        completed_countdown_levels.personal_best(level.id)
      ]
    end
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
    num_countdowns_completed > 0 or num_speedruns_completed or num_openings_rounds_completed > 0
  end

  def all_time_high_scores?
    recent_high_scores? \
      or num_repetition_levels_completed > 0 \
      or num_infinity_puzzles_solved > 0
  end

  def recent_activity(limit = 10)
    activities = []
    since = 30.days.ago

    # Collect recent completions from different game modes
    activities += completed_haste_rounds.where('created_at >= ?', since).order(created_at: :desc).limit(limit).map do |round|
      {
        type: 'haste',
        type_display: 'Haste',
        date: round.created_at,
        score: round.score,
        url: '/haste'
      }
    end

    activities += completed_countdown_levels.where('created_at >= ?', since).order(created_at: :desc).limit(limit).map do |completion|
      {
        type: 'countdown',
        type_display: 'Countdown',
        date: completion.created_at,
        score: completion.score,
        url: '/countdown'
      }
    end

    activities += completed_speedruns.where('created_at >= ?', since).order(created_at: :desc).limit(limit).map do |speedrun|
      {
        type: 'speedrun',
        type_display: 'Speedrun',
        date: speedrun.created_at,
        score: speedrun.formatted_time_spent,
        url: '/speedrun'
      }
    end

    activities += completed_mate_in_one_rounds.where('created_at >= ?', since).order(created_at: :desc).limit(limit).map do |round|
      {
        type: 'mate-in-one',
        type_display: 'Mate in One',
        date: round.created_at,
        score: round.score,
        url: '/mate-in-one'
      }
    end

    activities += completed_rook_endgames_rounds.where('created_at >= ?', since).order(created_at: :desc).limit(limit).map do |round|
      {
        type: 'rook-endgames',
        type_display: 'Rook Endgames',
        date: round.created_at,
        score: round.score,
        url: '/rook-endgames'
      }
    end

    activities += completed_three_rounds.where('created_at >= ?', since).order(created_at: :desc).limit(limit).map do |round|
      {
        type: 'three',
        type_display: 'Three',
        date: round.created_at,
        score: round.score,
        url: '/three'
      }
    end

    # Add daily infinity puzzle activity
    infinity_puzzle_days = solved_puzzles.where('created_at >= ? AND game_mode = ?', since, 'infinity')
                                        .group('DATE(created_at)')
                                        .select('DATE(created_at) as date, COUNT(*) as count, MAX(created_at) as latest_time')
                                        .order('DATE(created_at) DESC')
                                        .limit(limit)

    activities += infinity_puzzle_days.map do |day_data|
      {
        type: 'infinity',
        type_display: 'Infinity',
        date: day_data.latest_time,
        score: "#{day_data.count} puzzle#{'s' if day_data.count != 1}",
        url: '/infinity'
      }
    end

    # Sort by date descending and take the most recent
    activities.sort_by { |a| a[:date] }.reverse.take(limit)
  end

  def sound_enabled?
    !!self.profile["sound_enabled"]
  end

  # Track unique puzzles solved across all game modes
  def track_solved_puzzles(puzzle_ids)
    return if puzzle_ids.blank?
    SolvedPuzzle.bulk_create_for_user(id, puzzle_ids)
  end

  # Get count of unique puzzles solved (using counter cache for performance)
  def unique_puzzles_solved_count
    solved_puzzles_count
  end

  # Get most recently solved puzzles
  def recently_solved_puzzles(limit = 10)
    SolvedPuzzle.recently_solved_for_user(id, limit)
  end

  # Get puzzles first solved on a specific date
  def puzzles_first_solved_on(date)
    SolvedPuzzle.first_solved_on(id, date)
  end

  private

  def format_level_date(date_string)
    # Handle date strings like "2025-09-18" and convert to "Sep 18, 2025"
    begin
      Date.parse(date_string).strftime("%b %d, %Y")
    rescue
      # Fallback to original string if parsing fails
      date_string
    end
  end

  # user settings

  def set_sound_enabled(enabled)
    self.profile["sound_enabled"] = enabled
    self.save!
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
