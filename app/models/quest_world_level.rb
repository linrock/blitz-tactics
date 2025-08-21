class QuestWorldLevel < ActiveRecord::Base
  belongs_to :quest_world
  has_many :completed_quest_world_levels, dependent: :destroy
  
  validates :quest_world, presence: true
  validates :puzzle_ids, presence: true
  validates :success_criteria, presence: true

  # Default scope for ordering
  default_scope -> { order(:number, :id) }

  # Validate success criteria structure
  validate :validate_success_criteria_format
  
  # Scopes for querying by criteria
  scope :with_time_limit, -> { where("success_criteria ? 'time_limit'") }
  scope :without_time_limit, -> { where("NOT (success_criteria ? 'time_limit')") }
  scope :requiring_puzzles, ->(count) { where("(success_criteria->>'puzzles_solved')::int = ?", count) }
  scope :with_time_limit_under, ->(seconds) { where("(success_criteria->>'time_limit')::int < ?", seconds) }
  scope :containing_puzzle, ->(puzzle_id) { where("? = ANY(puzzle_ids)", puzzle_id) }
  
  private
  
  def validate_success_criteria_format
    return unless success_criteria.present?
    
    unless success_criteria.is_a?(Hash)
      errors.add(:success_criteria, "must be a valid JSON object")
      return
    end
    
    # Must have puzzles_solved
    unless success_criteria['puzzles_solved'].present? && success_criteria['puzzles_solved'].is_a?(Integer) && success_criteria['puzzles_solved'] > 0
      errors.add(:success_criteria, "must include 'puzzles_solved' as a positive integer")
    end
    
    # If time_limit is present, it must be a positive integer
    if success_criteria['time_limit'].present? && (!success_criteria['time_limit'].is_a?(Integer) || success_criteria['time_limit'] <= 0)
      errors.add(:success_criteria, "time_limit must be a positive integer (seconds)")
    end
  end
  
  public
  
  # Check if a user has completed this level
  def completed_by?(user)
    completed_quest_world_levels.exists?(user: user)
  end
  
  # Complete this level for a user and check world completion
  def complete_for_user!(user)
    return if completed_by?(user)
    
    CompletedQuestWorldLevel.complete_level!(user, self)
    CompletedQuestWorld.check_world_completion!(user, quest_world)
  end
  
  # Get all users who completed this level
  def completed_users
    User.joins(:completed_quest_world_levels).where(completed_quest_world_levels: { quest_world_level: self })
  end
  
  # Helper methods for success criteria
  def puzzles_required
    success_criteria['puzzles_solved'] || 0
  end
  
  def time_limit_seconds
    success_criteria['time_limit']
  end
  
  def has_time_limit?
    time_limit_seconds.present?
  end
  
  # Get puzzle count
  def puzzle_count
    puzzle_ids.length
  end
  
  # Check if level has enough puzzles for success criteria
  def has_enough_puzzles?
    puzzle_count >= puzzles_required
  end
  
  # Get a description of success criteria
  def success_criteria_description
    desc = "Solve #{puzzles_required} puzzle#{'s' if puzzles_required != 1}"
    desc += " in #{time_limit_seconds} seconds" if has_time_limit?
    desc
  end
  
  # Validate that a completion attempt meets the criteria
  def meets_success_criteria?(puzzles_solved, time_taken = nil)
    return false if puzzles_solved < puzzles_required
    return false if has_time_limit? && time_taken && time_taken > time_limit_seconds
    true
  end
end
