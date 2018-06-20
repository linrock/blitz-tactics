# Tracks the time it takes for a user to complete a single round of
# a precision level

class CompletedRound < ActiveRecord::Base
  belongs_to :level_attempt

  validates_numericality_of :time_elapsed, :less_than => 900

  def formatted_time_spent
    Time.at(time_elapsed).strftime("%M:%S").gsub(/^0/, '')
  end
end
