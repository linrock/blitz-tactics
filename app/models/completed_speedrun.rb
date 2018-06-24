# Tracks the time it takes for a user to complete a single round of
# a repetition level

class CompletedSpeedrun < ActiveRecord::Base
  belongs_to :user
  belongs_to :speedrun_level

  validates :elapsed_time_ms, numericality: { greater_than: 1_000 }

  default_scope { order(elapsed_time_ms: :asc) } # first = personal best

  def formatted_time_spent
    Time.at(time_elapsed).strftime("%M:%S").gsub(/^0/, '')
  end

  def self.personal_best(speedrun_level_id)
    where(speedrun_level_id: speedrun_level_id).first.elapsed_time_ms
  end

  def self.formatted_fastest_time
    best_time_ms = first&.elapsed_time_ms
    return 'None' unless best_time_ms.present?
    sprintf("%0.1fs" % (best_time_ms.to_f / 1000))
  end

  def self.formatted_personal_best(speedrun_level_id)
    best_time_ms = where(speedrun_level_id: speedrun_level_id).first.elapsed_time_ms
    return 'None' unless best_time_ms.present?
    sprintf("%0.1fs" % (best_time_ms.to_f / 1000))
  end
end
