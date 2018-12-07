# record of the countdown levels that a player has completed

class CompletedCountdownLevel < ActiveRecord::Base
  belongs_to :user
  belongs_to :countdown_level
end
