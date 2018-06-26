# tracks the repetition levels that a player has completed
# to determine the next level

class CompletedRepetitionLevel < ActiveRecord::Base
  belongs_to :user
  belongs_to :repetition_level
end
