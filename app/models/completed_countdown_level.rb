# record of the countdown levels that a player has completed

class CompletedCountdownLevel < ActiveRecord::Base
  belongs_to :user
  belongs_to :countdown_level

  def self.personal_best(countdown_level_id)
    where(countdown_level_id: countdown_level_id)
      .order(score: :desc)
      .first&.score
  end
end
