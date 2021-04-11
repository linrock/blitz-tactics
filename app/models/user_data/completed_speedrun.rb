# Tracks the time it takes for a user to complete a single round of
# a repetition level

class CompletedSpeedrun < ActiveRecord::Base
  belongs_to :user
  belongs_to :speedrun_level

  validates :elapsed_time_ms, numericality: { greater_than: 10_000 }

  def formatted_time_spent
    sprintf("%0.1fs" % (elapsed_time_ms.to_f / 1000))
  end

  def self.personal_best(speedrun_level_id)
    where(speedrun_level_id: speedrun_level_id)
      .order(elapsed_time_ms: :asc)
      .first&.elapsed_time_ms
  end

  def self.formatted_fastest_time
    best_time_ms = order(elapsed_time_ms: :asc).first&.elapsed_time_ms
    return 'None' unless best_time_ms.present?
    sprintf("%0.1fs" % (best_time_ms.to_f / 1000))
  end

  def self.formatted_personal_best(speedrun_level_id)
    best_time_ms = personal_best(speedrun_level_id)
    return 'None' unless best_time_ms.present?
    sprintf("%0.1fs" % (best_time_ms.to_f / 1000))
  end
end
