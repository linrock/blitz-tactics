class ScoreboardController < ApplicationController

  def index
    @ranked_users = User.all.sort_by do |user|
      -user.highest_level_unlocked
    end.take(50)
  end

end
