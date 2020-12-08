# tracks the score from completing a set of threes puzzles

class CompletedThreeRound < ActiveRecord::Base
  belongs_to :user

  validates :score, presence: true, numericality: { greater_than: 0 }

  def formatted_time_spent
    Time.at(elapsed_time_ms / 1000).strftime("%M:%S").gsub(/^0/, '')
  end

  # get high scores from a rolling time period
  def self.high_scores(since)
    where('created_at >= ?', since)
      .group(:user_id).maximum(:score)
      .sort_by {|user_id, score| -score }.take(5)
      .map do |user_id, score|
        [
          User.find_by(id: user_id),
          score
        ]
      end
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
