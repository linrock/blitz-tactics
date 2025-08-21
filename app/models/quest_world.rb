class QuestWorld < ActiveRecord::Base
  has_many :quest_world_levels, dependent: :destroy
  has_many :completed_quest_worlds, dependent: :destroy
  has_many :completed_quest_world_levels, through: :quest_world_levels
  
  validates :description, presence: true
  # Background is optional - can be empty
  
  # Check if a user has completed this world
  def completed_by?(user)
    completed_quest_worlds.exists?(user: user)
  end
  
  # Get completion percentage for a user
  def completion_percentage(user)
    return 0 if quest_world_levels.count == 0
    
    completed_count = completed_quest_world_levels.where(user: user).count
    (completed_count.to_f / quest_world_levels.count * 100).round
  end
  
  # Get all users who completed this world
  def completed_users
    User.joins(:completed_quest_worlds).where(completed_quest_worlds: { quest_world: self })
  end
end
