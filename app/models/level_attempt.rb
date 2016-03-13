# Data associated with an attempt a player makes on a level
#
class LevelAttempt < ActiveRecord::Base
  belongs_to :user
  belongs_to :level

  has_many :completed_rounds
end
