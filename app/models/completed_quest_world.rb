class CompletedQuestWorld < ActiveRecord::Base
  belongs_to :user
  belongs_to :quest_world
  
  validates :user, presence: true
  validates :quest_world, presence: true
  validates :completed_at, presence: true
  validates :user_id, uniqueness: { scope: :quest_world_id }
  
  scope :for_user, ->(user) { where(user: user) }
  scope :for_world, ->(world) { where(quest_world: world) }
  scope :completed_on, ->(date) { where(completed_at: date.beginning_of_day..date.end_of_day) }
  
  def self.complete_world!(user, quest_world)
    create!(
      user: user,
      quest_world: quest_world,
      completed_at: Time.current
    )
  end
  
  # Check if user has completed all levels in the world
  def self.check_world_completion!(user, quest_world)
    total_levels = quest_world.quest_world_levels.count
    completed_levels = CompletedQuestWorldLevel.joins(:quest_world_level)
                                              .where(user: user, quest_world_levels: { quest_world: quest_world })
                                              .count
    
    if total_levels > 0 && completed_levels >= total_levels
      complete_world!(user, quest_world) unless exists?(user: user, quest_world: quest_world)
    end
  end
end
