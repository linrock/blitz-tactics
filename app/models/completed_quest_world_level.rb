class CompletedQuestWorldLevel < ActiveRecord::Base
  belongs_to :user
  belongs_to :quest_world_level
  
  validates :user, presence: true
  validates :quest_world_level, presence: true
  validates :completed_at, presence: true
  validates :user_id, uniqueness: { scope: :quest_world_level_id }
  
  scope :for_user, ->(user) { where(user: user) }
  scope :for_level, ->(level) { where(quest_world_level: level) }
  scope :completed_on, ->(date) { where(completed_at: date.beginning_of_day..date.end_of_day) }
  
  def self.complete_level!(user, quest_world_level)
    create!(
      user: user,
      quest_world_level: quest_world_level,
      completed_at: Time.current
    )
  end
end
