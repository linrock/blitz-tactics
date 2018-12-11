# tracks the score from completing a set of haste puzzles

class CompletedHasteRound < ActiveRecord::Base
  belongs_to :user

  validates :score, presence: true, numericality: { greater_than: 0 }

  def formatted_time_spent
    Time.at(elapsed_time_ms / 1000).strftime("%M:%S").gsub(/^0/, '')
  end

  # best score of a particular day
  def self.personal_best(day)
    where(
      'created_at >= ? AND created_at <= ?',
      day.beginning_of_day,
      day.end_of_day
    ).maximum(:score)
  end
end
