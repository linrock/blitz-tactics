# tracks the time a user takes to make it through all repetition puzzles in a round

class CompletedRepetitionRound < ActiveRecord::Base
  belongs_to :user
  belongs_to :repetition_level

  validates :elapsed_time_ms, presence: true, numericality: { greater_than: 1_000 }

  def formatted_time_spent
    Time.at(elapsed_time_ms / 1000).strftime("%M:%S").gsub(/^0/, '')
  end
end
