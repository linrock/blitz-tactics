class CompletedRound < ActiveRecord::Base
  belongs_to :level_attempt

  def formatted_time_spent
    Time.at(time_elapsed).strftime("%M:%S").gsub(/^0/, '')
  end

end
