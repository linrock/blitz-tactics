# Tracks the time it takes for a user to complete a single round of
# a repetition level

class CompletedSpeedrun < ActiveRecord::Base
  belongs_to :user
  belongs_to :speedrun_level

  validates :elapsed_time_ms, numericality: { greater_than: 1_000 }

  default_scope { order(elapsed_time_ms: :asc) }

  def formatted_time_spent
    Time.at(time_elapsed).strftime("%M:%S").gsub(/^0/, '')
  end

  def self.personal_best(speedrun_level_id)
    where(speedrun_level_id: speedrun_level_id).first.elapsed_time_ms
  end
end
