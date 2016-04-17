class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :validatable,
  # :recoverable, and :omniauthable

  devise :database_authenticatable, :registerable, :rememberable, :trackable,
         :validatable

  has_many :level_attempts

  after_initialize :set_default_profile

  validate :validate_username

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
    self.profile["levels_unlocked"].max
  end

  def round_times_for_level(level_id)
    attempt = level_attempts.find_by_id(level_id)
    return [] unless attempt
    rounds = attempt.completed_rounds.order("id DESC")
    rounds.map(&:formatted_time_spent)
  end

  private

  def email_required?
    false
  end

  def set_default_profile
    self.profile ||= { "levels_unlocked": [1] }
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
  end

end
